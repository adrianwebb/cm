
nucleon_require(File.dirname(__FILE__), :cm_action)

#---

module Nucleon
module Plugin
class PackageAction < Nucleon.plugin_class(:nucleon, :cm_action)

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
      register_package_provider :package_provider, Nucleon.type_default(:CM, :plan), [
        'cm.action.package.base.options.package_provider',
        'cm.action.package.base.errors.package_provider'
      ]
      register_str :name, nil, 'cm.action.package.base.options.name'
      register_str :root_path, File.join(ENV['HOME'], 'CM'), 'cm.action.package.base.options.root_path'

      # Loading additional registered package plugin options
      Nucleon.loaded_plugins(:CM, :package).each do |provider, data|
        data[:class].options(myself)
      end

      yield if block_given?
    end
  end

  #---

  def arguments
    [:name]
  end

  #-----------------------------------------------------------------------------
  # Properties

  def package_directory
    File.join(settings[:root_path], settings[:name])
  end

  def package
    @package
  end

  #-----------------------------------------------------------------------------
  # Operations

  def execute(&block)
    super do
      block.call if initialize_package
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def initialize_package
    @package = CM.package(settings[:name], extended_config(:package, {
      :action_settings => Nucleon::Config.ensure(settings).export,
      :path            => package_directory
    }), settings[:package_provider])
  end
end
end
end
