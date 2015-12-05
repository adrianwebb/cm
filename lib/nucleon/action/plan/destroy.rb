
module Nucleon
module Action
module Plan
class Destroy < Nucleon.plugin_class(:nucleon, :plan_action)

  #-----------------------------------------------------------------------------
  # Info

  def self.describe
    super(:plan, :destroy, 600)
  end

  #-----------------------------------------------------------------------------
  # Settings

  def configure
    super do

    end
  end

  #---

  def arguments
    []
  end

  #-----------------------------------------------------------------------------
  # Action operations

  def execute
    super do
      info('start')
    end
  end
end
end
end
end
