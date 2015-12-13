
module CM
module Resource
class Keypair < Nucleon.plugin_class(:CM, :resource)

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

  #-----------------------------------------------------------------------------
  # Operations

  def execute
    super do
      success = true
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
