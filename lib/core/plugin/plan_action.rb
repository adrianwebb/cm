
nucleon_require(File.dirname(__FILE__), :cm_action)

#---

module Nucleon
module Plugin
class PlanAction < Nucleon.plugin_class(:nucleon, :cm_action)

  #-----------------------------------------------------------------------------
  # Constuctor / Destructor

  def normalize(reload)
    super do
      yield if block_given?
    end
  end

  #-----------------------------------------------------------------------------
  # Property accessor / modifiers

  def configure
    super do
      register_plan_provider :plan, Nucleon.type_default(:CM, :plan), [
        'cm.action.plan.base.options.plan_provider',
        'cm.action.plan.base.errors.plan_provider'
      ] do |value, success|
        @plan = CM.plan(plugin_name, {}, value) if success
      end
      yield if block_given?
    end
  end

  #-----------------------------------------------------------------------------
  # Properties

  def plan
    @plan
  end

  #-----------------------------------------------------------------------------
  # Operations

  def execute(&block)
    super do
      initialize_plan
      block.call
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
