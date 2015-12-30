
nucleon_require(File.dirname(__FILE__), :resource)

#---

module CM
module Plugin
class DockerResource < Nucleon.plugin_class(:CM, :resource)

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

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

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
    get(:host_input_directory, "/tmp/cm-data/input/#{plugin_instance_name}")
  end

  def input_directory
    get(:input_directory, '/opt/cm/volumes/input')
  end

  #---

  def host_output_directory
    get(:host_output_directory, "/tmp/cm-data/output/#{plugin_instance_name}")
  end

  def output_directory
    get(:output_directory, '/opt/cm/volumes/output')
  end

  #-----------------------------------------------------------------------------
  # Operations

  def operation_deploy
    super do
      results = nil

      # A fork in the road!
      if internal?
        results = yield if block_given?

        output_config = CM.configuration(extended_config(:resource_results, {
          :provider => get(:resource_output_provider, :file),
          :path => "#{output_directory}/config.json"
        }))
        output_config.import(Nucleon::Config.ensure(results).export)
        output_config.save
        Nucleon.remove_plugin(output_config)

        logger.info("Docker internal data: #{hash(results)}")
      else
        logger.info("Running deploy operation on #{plugin_provider} resource")

        results = action(plugin_provider, :deploy)
        logger.info("Docker return data: #{hash(results)}")

        myself.status = code.docker_exec_failed unless results
      end
      myself.data = results
      myself.status == code.success
    end
  end

  #-----------------------------------------------------------------------------
  # Docker resource operation execution

  def exec(command)
    data = nil

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
        Nucleon.remove_plugin(output_config)
      end
    end

    destroy_container
    data
  end

  #---

  def command(command, options = {})
    config         = Nucleon::Config.ensure(options)
    remove_command = false

    unless command.is_a?(Nucleon::Plugin::Command)
      command        = Nucleon.command(Nucleon::Config.new({ :command => command }, {}, true, false).import(config), :bash)
      remove_command = true
    end

    data = exec(command.to_s.strip) do |stream, message|
      yield(stream, message) if block_given?
    end

    Nucleon.remove_plugin(command) if remove_command
    data
  end

  #---

  def action(provider, operation)
    FileUtils.mkdir_p(host_input_directory)
    FileUtils.mkdir_p(host_output_directory)

    action_settings = Nucleon::Util::Data.clean(plan.action_settings)
    initialize_remote_config(action_settings)

    encoded_config = Nucleon::Util::CLI.encode(action_settings)
    action_config  = extended_config(:action, {
      :command => 'resource run',
      :data    => { :encoded  => encoded_config },
      :args    => [ provider, operation ]
    })
    action_config[:data][:log_level] = Nucleon.log_level if Nucleon.log_level

    results = command('cm', Nucleon::Util::Data.clean({
      :subcommand => action_config,
      :quiet      => Nucleon::Util::Console.quiet
    })) do |stream, message|
      yield(stream, message) if block_given?
    end

    FileUtils.rm_rf(host_input_directory)
    FileUtils.rm_rf(host_output_directory)
    data
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def create_container
    container = nil
    gem_path = "#{ENV['GEM_HOME']}/gems/cm-#{CM.VERSION}"

    destroy_container

    container_env = []
    container_env << "NUCLEON_NO_PARALLEL=1" unless Nucleon.parallel?
    container_env << "NUCLEON_NO_COLOR=1" unless Nucleon::Util::Console.use_colors

    @container = Docker::Container.create({
      'name' => plugin_instance_name,
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
    # Generate action settings file
    settings = CM.configuration(extended_config(:container_input_settings_data, {
      :provider => get(:container_input_settings_provider, :file),
      :path => "#{host_input_directory}/action_settings.json"
    }))
    settings.import(action_settings)
    settings.save

    Nucleon.remove_plugin(settings)

    # Generate and store plan configuration in local input directory
    config = CM.configuration(extended_config(:container_input_config_data, {
      :provider => get(:container_input_config_provider, :file),
      :path => "#{host_input_directory}/config.json"
    }))
    config.import(plan.manifest_config)
    config.save

    Nucleon.remove_plugin(config)

    # Generate and store plan tokens in local input directory
    tokens = CM.configuration(extended_config(:container_input_token_data, {
      :provider => get(:container_input_token_provider, :file),
      :path => "#{host_output_directory}/tokens.json"
    }))
    tokens.import(plan.tokens)
    tokens.save

    Nucleon.remove_plugin(tokens)

    # Customize action settings
    action_settings[:resource_config] = myself.settings
    action_settings[:settings_path] = "#{input_directory}/action_settings.json"
    action_settings[:plan_path] = plan_directory
    action_settings[:config_provider] = 'file'
    action_settings[:config_path] = "#{input_directory}/config.json"
    action_settings[:token_provider] = 'file'
    action_settings[:token_path] = output_directory
    action_settings[:token_file] = 'tokens.json'
    action_settings[:key_path] = key_directory
  end
  protected :initialize_remote_config


  #---

  def destroy_container
    containers = Docker::Container.all({ :all => 1 })

    # TODO: Fix occasional crashed actor issue when in parallel mode
    containers.each do |cont|
      if cont.info.key?('Names') && cont.info['Names'].include?("/#{plugin_instance_name}")
        cont.kill!
        cont.remove
      end
    end
    @container = nil
  end
  protected :destroy_container

  #---

  def render_docker_message(stream, message)
    if stream == 'stderr'
      warn(message, { :i18n => false })
    else
      info(message, { :i18n => false })
    end
  end
end
end
end
