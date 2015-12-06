
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
      register_plan_provider :plan_provider, Nucleon.type_default(:CM, :plan), [
        'cm.action.plan.base.options.plan',
        'cm.action.plan.base.errors.plan'
      ]
      register_directory :plan_path, Dir.pwd, [
        'cm.action.plan.base.options.plan_path',
        'cm.action.plan.base.errors.plan_path'
      ]
      register_directory :key_path, Dir.pwd, [
        'cm.action.plan.base.options.key_path',
        'cm.action.plan.base.errors.key_path'
      ]
      register_file :manifest, 'plan.yml', [
        'cm.action.plan.base.options.manifest',
        'cm.action.plan.base.errors.manifest'
      ]
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

  def initialize_plan
    @plan = CM.plan(plugin_name, {
      :system_config => settings[:system_config],
      :directory     => settings[:plan_path],
      :key_directory => settings[:key_path],
      :manifest      => settings[:manifest]
    }, settings[:plan_provider])
  end
end
end
end
