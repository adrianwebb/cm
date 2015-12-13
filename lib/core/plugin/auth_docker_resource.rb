
nucleon_require(File.dirname(__FILE__), :docker_resource)

#---

module CM
module Plugin
class AuthDockerResource < Nucleon.plugin_class(:CM, :docker_resource)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    if settings[:docker_username] && settings[:docker_password] && settings[:docker_email]
      begin
        Docker.authenticate!({
          'username' => settings[:docker_username],
          'password' => settings[:docker_password],
          'email' => settings[:docker_email]
        })
      rescue Docker::Error::AuthenticationError => error
        error('authentication_failed', { :error => error.message })
        raise error
      end
    else
      raise render_message('cm.resource.docker.info.no_credentials', {
        :username_option => 'docker_username',
        :password_option => 'docker_password',
        :email_option => 'docker_email'
      })
    end

    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  #-----------------------------------------------------------------------------
  # Operations

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
