
nucleon_require(File.dirname(__FILE__), :resource)

#---

module CM
module Plugin
class DockerResource < Nucleon.plugin_class(:CM, :resource)

  #-----------------------------------------------------------------------------

  def self.options(action)
    action.register_bool :docker, true, 'cm.action.docker_resource.options.docker'
    action.register_bool :keep_alive, false, 'cm.action.docker_resource.options.keep_alive'
  end

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    require 'docker'
    super

    codes :docker_exec_failed

    settings[:docker_protocol] ||= 'unix'
    settings[:docker_sock] ||= '/var/run/docker.sock'
    settings[:docker_host] ||= nil
    settings[:docker_port] ||= '127.0.0.1'
    settings[:docker_image] ||= 'awebb/cm'

    if settings[:docker_host].nil?
      Docker.url = "#{settings[:docker_protocol]}://#{settings[:docker_sock]}"
    else
      Docker.url = "#{settings[:docker_protocol]}://#{settings[:docker_host]}:#{settings[:docker_port]}"
    end

    Docker.options[:write_timeout] = timeout
    Excon.defaults[:write_timeout] = timeout
    Docker.options[:read_timeout] = timeout
    Excon.defaults[:read_timeout] = timeout

    yield if block_given?
  end

  #---

  def remove_plugin
    destroy_container
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    true
  end

  #---

  def internal?
    File.exist?('/.dockerinit')
  end

  def dockerize?
    action_settings[:docker] || settings[:docker]
  end

  def keep_alive?
    action_settings[:keep_alive] || settings[:keep_alive]
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def docker_id
    @docker_id ||= "#{id}-#{Time.now.strftime('%Y-%m-%dT%H-%M-%S%Z')}"
  end

  def image
    get(:image, 'awebb/cm').to_s
  end

  #---

  def startup_commands
    get(:startup_commands, ['bash'])
  end

  #---

  def container
    @container
  end

  #---

  def plan_directory
    get(:plan_directory, '/opt/cm/volumes/plan')
  end

  def key_directory
    get(:key_directory, '/opt/cm/volumes/keys')
  end

  #---

  def host_input_directory
    get(:host_input_directory, "/tmp/cm-data/input/#{docker_id}")
  end

  def input_directory
    get(:input_directory, "/opt/cm/volumes/input")
  end

  #---

  def host_output_directory
    get(:host_output_directory, "/tmp/cm-data/output/#{docker_id}")
  end

  def output_directory
    get(:output_directory, "/opt/cm/volumes/output")
  end

  #-----------------------------------------------------------------------------
  # Operations

  def operation_deploy
    operation_run(:deploy) do
      data = super
      child_data = yield if block_given?
      Nucleon::Util::Data.merge([ data, hash(child_data) ], true, false)
    end
  end

  def operation_destroy
    operation_run(:destroy) do
      data = super
      child_data = yield if block_given?
      Nucleon::Util::Data.merge([ data, hash(child_data) ], true, false)
    end
  end

  #---

  def operation_run(operation)
    data = {}

    # A fork in the road!
    if !dockerize? || internal?
      data = yield if block_given?

      if dockerize?
        FileUtils.mkdir_p(output_directory)

        output_config = CM.configuration(extended_config(:resource_results, {
          :provider => get(:resource_output_provider, :file),
          :path => "#{output_directory}/config.json"
        }))
        output_config.import(Nucleon::Config.ensure(data).export)
        output_config.save
      end

      logger.info("Docker internal data: #{hash(data)}")
    else
      info('cm.resource.docker_resource.info.run_dockerized', { :image => Nucleon.yellow(image), :id => id, :op => operation, :time => Nucleon.purple(Time.now.utc.strftime('%Y-%m-%d %H:%M:%S %Z')) })
      logger.info("Running #{operation} operation on #{plugin_provider} resource")

      data = action(plugin_provider, operation)
      logger.info("Docker return data: #{hash(data)}")
    end
    data
  end

  #-----------------------------------------------------------------------------
  # Docker resource operation execution

  def exec(command)
    data = {}

    create_container

    results = container.exec(['bash', '-l', '-c', command]) do |stream, message|
      unless message.match(/stdin\:\s+is not a tty/)
        render_docker_message(stream, message)
        yield(stream, message) if block_given?
      end
    end

    if results[2] == 0
      if output_config = CM.configuration(extended_config(:resource_results, {
        :provider => get(:resource_result_provider, :file),
        :path => "#{host_output_directory}/config.json"
      }))
        data = Nucleon::Util::Data.clone(output_config.export)
      end
    else
      myself.status = code.docker_exec_failed
    end
    data
  ensure
    destroy_container
  end

  #---

  def command(command, options = {})
    command = Nucleon.command(Nucleon::Config.new({ :command => command }, {}, true, false).import(options), :bash)
    Nucleon.remove_plugin(command)

    exec(command.to_s.strip) do |stream, message|
      yield(stream, message) if block_given?
    end
  end

  #---

  def action(provider, operation)
    FileUtils.mkdir_p(host_input_directory)
    FileUtils.mkdir_p(host_output_directory)

    action_settings = Nucleon::Util::Data.clean(plan.action_settings)
    initialize_remote_config(action_settings)

    command('cm', Nucleon::Util::Data.clean({
      :subcommand => extended_config(:action, {
        :command => 'resource run',
        :data => { :encoded  => Nucleon::Util::CLI.encode(action_settings) },
        :args => [ provider, operation ]
      }),
      :quiet => Nucleon::Util::Console.quiet
    })) do |stream, message|
      yield(stream, message) if block_given?
    end
  ensure
    unless keep_alive?
      FileUtils.rm_rf(host_input_directory)
      FileUtils.rm_rf(host_output_directory)
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def create_container
    container = nil
    gem_path = "#{ENV['GEM_HOME']}/gems/cm-#{CM.VERSION}"

    destroy_container(true)

    container_env = []
    container_env << "NUCLEON_LOG=#{Nucleon.log_level}" if Nucleon.log_level
    container_env << "NUCLEON_NO_PARALLEL=1" unless Nucleon.parallel?
    container_env << "NUCLEON_NO_COLOR=1" unless Nucleon::Util::Console.use_colors

    @container = Docker::Container.create({
      'name' => docker_id,
      'Image' => image,
      'Cmd' => array(startup_commands),
      'Tty' => true,
      'Env' => container_env,
      'Volumes' => {
        plan_directory => {},
        key_directory => {},
        input_directory => {},
        output_directory => {},
        gem_path => {}
      },
      'HostConfig' => {
        'Binds' => [
          "#{plan.path}:#{plan_directory}:ro",
          "#{plan.key_directory}:#{key_directory}:rw",
          "#{host_input_directory}:#{input_directory}:ro", # config.yaml and tokens.json
          "#{host_output_directory}:#{output_directory}:rw", # ??.yaml and/or ??.json
          "#{gem_path}:#{gem_path}:ro"
        ]
      }
    })

    if @container
      @container.start!
    else
      error('cm.resource.docker.error.container_failed', {
        :image => image
      })
    end
  end
  protected :create_container

  #---

  def initialize_remote_config(action_settings)
    # Generate and store plan configuration in local input directory
    config = CM.configuration(extended_config(:container_input_config_data, {
      :provider => get(:container_input_config_provider, :file),
      :path => "#{host_input_directory}/config.json"
    }))
    config.import({ :config => plan.manifest_config })
    config.save

    # Generate and store plan tokens in local input directory
    tokens = CM.configuration(extended_config(:container_input_token_data, {
      :provider => get(:container_input_token_provider, :file),
      :path => "#{host_output_directory}/tokens.json"
    }))
    tokens.import(plan.tokens)
    tokens.save

    # Customize action settings
    action_settings[:resource_config] = myself.settings
    action_settings[:plan_path] = plan_directory
    action_settings[:manifest] = plan.manifest_file
    action_settings[:config_provider] = 'file'
    action_settings[:config_path] = "#{input_directory}/config.json"
    action_settings[:token_provider] = 'file'
    action_settings[:token_path] = output_directory
    action_settings[:token_file] = 'tokens.json'
    action_settings[:key_path] = key_directory
  end
  protected :initialize_remote_config


  #---

  def destroy_container(override = false)
    if override || !keep_alive?
      containers = Docker::Container.all({ :all => 1 })

      # TODO: Fix occasional crashed actor issue when in parallel mode
      containers.each do |cont|
        if cont.info.key?('Names') && cont.info['Names'].include?("/#{docker_id}")
          cont.kill!
          cont.remove
        end
      end
      @container = nil
    end
  end
  protected :destroy_container

  #---

  def render_docker_message(stream, message)
    if stream == 'stderr'
      warn("(#{Nucleon.red(image)})>#{message}", { :i18n => false, :prefix => false })
    else
      info("(#{Nucleon.yellow(image)})>#{message}", { :i18n => false, :prefix => false })
    end
  end
  protected :render_docker_message
end
end
end
