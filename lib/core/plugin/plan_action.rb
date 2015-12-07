
nucleon_require(File.dirname(__FILE__), :cm_action)

#---

module Nucleon
module Plugin
class PlanAction < Nucleon.plugin_class(:nucleon, :cm_action)

  include Mixin::Action::Project

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
      register_str :plan_path, Dir.pwd, [
        'cm.action.plan.base.options.plan_path',
        'cm.action.plan.base.errors.plan_path'
      ]
      register_str :manifest, 'plan.yml', [
        'cm.action.plan.base.options.manifest',
        'cm.action.plan.base.errors.manifest'
      ]
      register_directory :key_path, Dir.pwd, [
        'cm.action.plan.base.options.key_path',
        'cm.action.plan.base.errors.key_path'
      ]

      project_config

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
    @plan = CM.plan(plugin_name, extended_config(:plan, {
      :path             => settings[:plan_path],
      :key_directory    => settings[:key_path],
      :manifest_file    => settings[:manifest],
      :project_provider => settings[:project_provider],
      :url              => settings[:project_reference],
      :revision         => settings[:project_revision]
    }), settings[:plan_provider])
  end
end
end
end
