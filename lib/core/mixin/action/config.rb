
module Nucleon
module Mixin
module Action
module Config

  #-----------------------------------------------------------------------------
  # Settings

  def config_config
    register_str :config_dir, CM.config_dir, 'nucleon.mixin.action.config.options.config_dir' do |value|
      success = true

      if value
        directory = File.expand_path(value)

        # Configuration directory exists
        if File.exist?(directory)
          # Get all configurations
          import_system_config(directory)

          # No configuration available?
          success = false if @system_config.nil?
        else
          # Non existent configuration directory
          warn('nucleon.mixin.action.config.errors.config_dir', { :directory => directory })
          success = false
        end
      end
      success
    end
  end

  #---

  def config_ignore
    [ :config_dir ]
  end

  #-----------------------------------------------------------------------------
  # Properties

  #-----------------------------------------------------------------------------
  # Utilities

  def import_system_config(directory)
    @system_config = {}

    # Merge all system configurations
    Nucleon.loaded_plugins(:nucleon, :translator).each do |provider, info|
      Dir.glob(::File.join(directory, '**', "*.#{provider}")).each do |file|
        logger.debug("Merging system configurations from: #{file}")
        if config_data = parse_config_file(file)
          @system_config = Util::Data.merge([ @system_config, config_data ], true, false)
        end
      end
    end

    # Values are already set from parameters and validation is just starting
    @system_config.each do |key, value|
      # TODO: Some error handling here if config key doesn't exist
      # For instance, if extra properties in config file
      if !config.has_key?(key) || settings[key] == config[key].default
        settings[key] = value
      end
    end
  end

  #---

  def parse_config_file(file)
    begin
      provider   = File.extname(file).sub(/^\./, '')
      translator = Nucleon.translator({}, provider) if provider
      raise I18n.t('nucleon.mixin.action.config.errors.translator', { :provider => provider, :file => file }) unless translator
      config_data = translator.parse(Util::Disk.read(file))
    rescue => error
      warn('nucleon.mixin.action.config.errors.config_file', { :file => file })
      warn(error.message, { :i18n => false })
      config_data = nil
    end
    config_data
  end
end
end
end
end
