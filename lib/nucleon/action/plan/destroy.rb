
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
      codes :destroy_failed
    end
  end

  #-----------------------------------------------------------------------------
  # Action operations

  def execute
    super do
      info('start')
      unless plan.execute(:destroy)
        myself.status = code.destroy_failed
      end
    end
  end
end
end
end
end
