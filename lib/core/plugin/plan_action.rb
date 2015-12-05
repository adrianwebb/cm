
nucleon_require(File.dirname(__FILE__), :cm_action)

#---

module Nucleon
module Plugin
class PlanAction < Plugin::CmAction

  #-----------------------------------------------------------------------------
  # Constuctor / Destructor

  def normalize(reload)
    super do

    end
  end

  #-----------------------------------------------------------------------------
  # Property accessor / modifiers

  def configure
    super do
      yield if block_given?
    end
  end

  #-----------------------------------------------------------------------------
  # Settings

  #-----------------------------------------------------------------------------
  # Operations

  def execute(&block)
    super do
      block.call
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
