
module Nucleon
module Mixin
module Action
module Config

  #-----------------------------------------------------------------------------
  # Settings

  def config_config
    register_str :config_path, CM.config_path, 'nucleon.mixin.action.config.options.config_path' do |value|
      success = true

      if value
        path = File.expand_path(value)

        if File.exist?(path)
          success = false unless import_system_config(path)
        else
          warn('nucleon.mixin.action.config.errors.config_path', { :path => path })
          success = false
        end
      end
      success
    end
  end

  #---

  def config_ignore
    [ :config_path ]
  end

  #-----------------------------------------------------------------------------
  # Properties

  #-----------------------------------------------------------------------------
  # Utilities

  def import_system_config(path)
    config_provider = (File.directory?(path) ? :directory : :file)
    system_config = CM.configuration(extended_config(:system_config, {
      :path => path,
      :translator_error => 'nucleon.mixin.action.config.errors.translator',
      :config_error => 'nucleon.mixin.action.config.errors.config_file'
    }), config_provider).parse

    unless system_config.nil?
      # Values are already set from parameters and validation is just starting
      system_config.export.each do |key, value|
        # TODO: Some error handling here if config key doesn't exist
        # For instance, if extra properties in config file
        if !config.has_key?(key) || settings[key] == config[key].default
          settings[key] = value
        end
      end
    end
    system_config.nil? ? false : true
  end
end
end
end
end
