
module Nucleon
module Action
module Resource
class Run < Nucleon.plugin_class(:nucleon, :plan_action)

  #-----------------------------------------------------------------------------
  # Info

  def self.describe
    super(:resource, :run, 500)
  end

  #-----------------------------------------------------------------------------
  # Checks

  def strict?
    false
  end

  #-----------------------------------------------------------------------------
  # Settings

  def configure
    super do
      codes :run_failed

      register_str :provider, nil
      register_str :operation, nil
    end
  end

  #---

  def arguments
    [:provider, :operation]
  end

  #-----------------------------------------------------------------------------
  # Action operations

  def execute
    super do
      resource = plan.create_resource(settings[:resource_config])
      resource.execute(settings[:operation])

      myself.status = code.run_failed unless resource.status == code.success
    end
  end
end
end
end
end
