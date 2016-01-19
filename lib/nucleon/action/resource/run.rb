
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
      resource = nil

      begin
        if plan.execute(settings[:operation], true)
          resource = plan.create_resource(settings[:resource_config])
          resource.execute(settings[:operation])
        end
        myself.status = code.run_failed unless resource && resource.status == code.success

      rescue => error
        logger.error("Resource #{resource.id} #{settings[:operation]} experienced an error:")
        logger.error(error.inspect)
        logger.error(error.message)
        logger.error(Nucleon::Util::Data.to_yaml(error.backtrace))

        error('resource_execution', { :id => resource.id, :operation => settings[:operation], :message => error.message })
        myself.status = code.run_failed
      end
    end
  end
end
end
end
end
