
module CM
module Resource
class Variables < Nucleon.plugin_class(:CM, :resource)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super
    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

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
