
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
  # Checks

  def strict?
    false
  end

  #-----------------------------------------------------------------------------
  # Property accessor / modifiers

  def configure
    super do
      register_plan_provider :plan_provider, Nucleon.type_default(:CM, :plan), [
        'cm.action.plan.base.options.plan',
        'cm.action.plan.base.errors.plan'
      ]
      register_str :plan_path, Dir.pwd, 'cm.action.plan.base.options.plan_path'

      register_configuration_provider :manifest_provider, :file, [
        'cm.action.plan.base.options.manifest_provider',
        'cm.action.plan.base.errors.manifest_provider'
      ]
      register_str :manifest, 'plan.yaml', 'cm.action.plan.base.options.manifest'

      register_configuration_provider :config_provider, :directory, [
        'cm.action.plan.base.options.config_provider',
        'cm.action.plan.base.errors.config_provider'
      ]
      register_str :config_path, Dir.pwd, 'cm.action.plan.base.options.config_path'

      register_configuration_provider :token_provider, :file, [
        'cm.action.plan.base.options.token_provider',
        'cm.action.plan.base.errors.token_provider'
      ]
      register_directory :token_path, Dir.pwd, [
        'cm.action.plan.base.options.token_path',
        'cm.action.plan.base.errors.token_path'
      ]
      register_str :token_file, 'tokens.json', 'cm.action.plan.base.options.token_file'

      register_directory :key_path, Dir.pwd, [
        'cm.action.plan.base.options.key_path',
        'cm.action.plan.base.errors.key_path'
      ]
      register_bool :trap, false, 'cm.action.plan.options.trap'

      register_sequence_provider :sequence_provider, Nucleon.type_default(:CM, :sequence), [
        'cm.action.plan.base.options.sequence_provider',
        'cm.action.plan.base.errors.sequence_provider'
      ]
      register_batch_provider :batch_provider, Nucleon.type_default(:CM, :batch), [
        'cm.action.plan.base.options.batch_provider',
        'cm.action.plan.base.errors.batch_provider'
      ]
      register_resource_provider :default_resource_provider, Nucleon.type_default(:CM, :resource), [
        'cm.action.plan.base.options.default_resource_provider',
        'cm.action.plan.base.errors.default_resource_provider'
      ]

      # Loading additional registered resource plugin options
      Nucleon.loaded_plugins(:CM, :resource).each do |resource, data|
        data[:class].options(myself)
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
      block.call if initialize_plan
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def initialize_plan
    @plan = CM.plan(plugin_name, extended_config(:plan, {
      :action_settings           => Nucleon::Config.ensure(settings).export,
      :path                      => settings[:plan_path],
      :config_provider           => settings[:config_provider],
      :config_path               => settings[:config_path],
      :key_directory             => settings[:key_path],
      :manifest_provider         => settings[:manifest_provider],
      :manifest_file             => settings[:manifest],
      :token_provider            => settings[:token_provider],
      :token_directory           => settings[:token_path],
      :token_file                => settings[:token_file],
      :trap                      => settings[:trap],
      :sequence_provider         => settings[:sequence_provider],
      :batch_provider            => settings[:batch_provider],
      :default_resource_provider => settings[:default_resource_provider]
    }), settings[:plan_provider])
  end
end
end
end
