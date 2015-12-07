
module CM
module Sequence
class Default < Nucleon.plugin_class(:CM, :sequence)

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

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
