
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

  def operation_deploy
    super do
      data = {}
    end
  end

  #---

  def operation_destroy
    super do
      data = {}
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
