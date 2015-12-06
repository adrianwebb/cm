
module Nucleon
module Action
module Plan
class Deploy < Nucleon.plugin_class(:nucleon, :plan_action)

  #-----------------------------------------------------------------------------
  # Info

  def self.describe
    super(:plan, :deploy, 700)
  end

  #-----------------------------------------------------------------------------
  # Settings

  def configure
    super do
      codes :deploy_failed
    end
  end

  #---

  def arguments
    [:manifest]
  end

  #-----------------------------------------------------------------------------
  # Action operations

  def execute
    super do
      info('start')
      unless plan.deploy(settings)
        myself.status = code.deploy_failed
      end
    end
  end
end
end
end
end
