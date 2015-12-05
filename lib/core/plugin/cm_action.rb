
module Nucleon
module Plugin
class CmAction < Nucleon.plugin_class(:nucleon, :action)

  include Mixin::Action::Config

  #-----------------------------------------------------------------------------
  # Constuctor / Destructor

  def normalize(reload)
    super do

    end
  end

  #-----------------------------------------------------------------------------
  # Property accessor / modifiers

  def self.namespace
    :cm
  end

  #---

  def configure
    super do
      config_config
      yield if block_given?
    end
  end

  #-----------------------------------------------------------------------------
  # Settings

  #-----------------------------------------------------------------------------
  # Operations

  def execute(&block)
    super(false, false) do
      block.call
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
