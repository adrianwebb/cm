
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

    codes :docker_exec_failed

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
    get(:internal, false)
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def image
    get(:image, 'awebb/cm').to_s
  end

  def image=image
    set(:image, image)
    @container = create_container(image, startup_commands)
  end

  #---

  def startup_commands
    get(:startup_commands, ['bash'])
  end

  def startup_commands=commands
    set(:startup_commands, array(commands))
    @container = create_container(image, commands)
  end

  #---

  def container
    @container
  end

  #-----------------------------------------------------------------------------
  # Operations

  def execute
    super do
      success = true

      if internal?
        success = yield if block_given?
      else
        @container = create_container(image, startup_commands)

        encoded_config = Util::CLI.encode(Util::Data.clean(settings))

        action_config  = extended_config(:container_action, {
          :command => provider,
          :data    => { :encoded  => encoded_config }
        })
        action_config[:data][:log_level] = Nucleon.log_level if Nucleon.log_level

        command_base  = 'cm'
        command_base  = "NUCLEON_NO_PARALLEL=1 #{command_base}" unless Nucleon.parallel?
        command_base  = "NUCLEON_NO_COLOR=1 #{command_base}" unless Nucleon::Util::Console.use_colors

        command = Nucleon.command({
          :command => command_base,
          :data    => { 'git-dir=' => repo.path },
          :subcommand => {
            :command => command.to_s.gsub('_', '-'),
            :flags   => flags,
            :data    => data,
            :args    => processed_args
          }
        }, command_provider)

        results = container.exec(["cm resource exec #{}"], { :stdout => false }) do |stream, message|
          render_docker_message(stream, message)
        end
        myself.status = code.docker_exec_failed unless results[2] == 0
      end
      success
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def create_container(image, startup_commands)
    container = nil

    destroy_container(plugin_instance_name)

    container = Docker::Container.create({
      'name' => plugin_instance_name,
      'Image' => image,
      'Cmd' => array(startup_commands),
      'Tty' => true
    })

    if container
      container.start!
    else
      error('cm.resource.docker.error.container_failed', {
        :command => command.to_s,
        :image => image
      })
    end
    container
  end
  protected :create_container


  #---

  def destroy_container(name)
    containers = Docker::Container.all({ :all => 1 })

    containers.each do |cont|
      if cont.info['Names'].include?("/#{name}")
        cont.kill!
        cont.remove
      end
    end
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
