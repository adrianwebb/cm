
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
    settings[:docker_image] ||= 'aweb/cm'

    if settings[:docker_host].nil?
      Docker.url = "#{settings[:docker_protocol]}://#{settings[:docker_sock]}"
    else
      Docker.url = "#{settings[:docker_protocol]}://#{settings[:docker_host]}:#{settings[:docker_port]}"
    end

    yield if block_given?
  end

  #---

  def remove_plugin
    destroy_container(plugin_instance_name)
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

  def config_directory
    get(:config_directory, '/opt/cm/volumes/config')
  end

  def token_directory
    get(:token_directory, '/opt/cm/volumes/token')
  end

  def key_directory
    get(:key_directory, '/opt/cm/volumes/keys')
  end

  #---

  def host_input_directory
    get(:host_input_directory, "/tmp/cm/input/#{plugin_instance_name}")
  end

  def input_directory
    get(:input_directory, '/opt/cm/volumes/input')
  end

  #---

  def host_output_directory
    get(:host_output_directory, "/tmp/cm/output/#{plugin_instance_name}")
  end

  def output_directory
    get(:output_directory, '/opt/cm/volumes/output')
  end

  #-----------------------------------------------------------------------------
  # Operations

  def operation_deploy
    super do
      data = nil

      # A fork in the road!
      if internal?
        info("Yay!!! We are here", { :i18n => false })
        data = yield if block_given?
      else
        data = action(plugin_provider, :deploy)
        myself.status = code.docker_exec_failed unless data
      end
      data
    end
  end

  #-----------------------------------------------------------------------------
  # Docker resource operation execution

  def exec(command)
    data = nil

    FileUtils.mkdir_p(host_output_directory)
    create_container

    results = container.exec(['bash', '-l', '-c', command]) do |stream, message|
      unless message.match(/stdin\:\s+is not a tty/)
        render_docker_message(stream, message)
        yield(stream, message) if block_given?
      end
    end

    if results[2] == 0
      if output_config = CM.configuration(extended_config(:resource_results, {
        :provider => get(:resource_result_provider, :directory),
        :path => host_output_directory
      }))
        data = Nucleon::Util::Data.clone(output_config.export)
        Nucleon.remove_plugin(output_config)
      end
    end

    destroy_container
    FileUtils.rm_rf(host_output_directory)
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
    encoded_config = Nucleon::Util::CLI.encode(Nucleon::Util::Data.clean(settings))
    action_config  = extended_config(:action, {
      :command => 'resource run',
      :data    => { :encoded  => encoded_config },
      :args    => [ provider, operation ]
    })
    action_config[:data][:log_level] = Nucleon.log_level if Nucleon.log_level

    data = command('cm', Nucleon::Util::Data.clean({
      :subcommand => action_config,
      :quiet      => Nucleon::Util::Console.quiet
    })) do |stream, message|
      yield(stream, message) if block_given?
    end
    data
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def create_container
    container = nil

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
        CM.config_path => {},
        plan_directory => {},
        config_directory => {},
        token_directory => {},
        key_directory => {},
        input_directory => {},
        output_directory => {}
      },
      'HostConfig' => {
        'Binds' => [
          "#{CM.config_path}:#{CM.config_path}:ro",
          "#{plan.path}:#{plan_directory}:ro",
          "#{plan.config_directory}:#{config_directory}:ro",
          "#{plan.token_directory}:#{token_directory}:rw",
          "#{plan.key_directory}:#{key_directory}:rw",
          "#{host_input_directory}:#{input_directory}:ro",
          "#{host_output_directory}:#{output_directory}:rw"
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

  def destroy_container
    containers = Docker::Container.all({ :all => 1 })

    containers.each do |cont|
      if cont.info['Names'].include?("/#{plugin_instance_name}")
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
