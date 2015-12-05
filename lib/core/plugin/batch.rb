
module CM
module Plugin
class Batch < Nucleon.plugin_class(:nucleon, :base)

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

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
