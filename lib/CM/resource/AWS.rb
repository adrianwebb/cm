
module CM
module Resource
class AWS < Nucleon.plugin_class(:CM, :docker_resource)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super
    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    true
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def template
    settings[:template]
  end

  #-----------------------------------------------------------------------------
  # Operations

  def operation_deploy
    super do
      if template.to_sym == :keypair
        info('deploy_keypair', { :id => id, :name => parameters[:Name], :prefix => false })
      else
        info('deploy_cloudformation', { :id => id, :prefix => false })
      end
      data = {}
    end
  end

  #---

  def operation_destroy
    super do
      if template.to_sym == :keypair
        info('destroy_keypair', { :id => id, :name => parameters[:Name], :prefix => false })
      else
        info('destroy_cloudformation', { :id => id, :prefix => false })
      end
      data = {}
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
