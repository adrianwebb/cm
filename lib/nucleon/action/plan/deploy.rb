
module Nucleon
module Action
module Plan
class Deploy < Plugin::PlanAction

  #-----------------------------------------------------------------------------
  # Info

  def self.describe
    super(:plan, :deploy, 700)
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
