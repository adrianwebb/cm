
module Nucleon
module Mixin
module Action
module Config

  #-----------------------------------------------------------------------------
  # Settings

  def config_config
    register_str :config_dir, CM.config_dir, 'nucleon.mixin.action.config.options.config_file' do |value|
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
    [ :config_file ]
  end

  #-----------------------------------------------------------------------------
  # Properties

  def system_config
    @system_config
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def import_system_config(directory)
    Nucleon.loaded_plugins(:nucleon, :translator).each do |provider, info|
      Dir.glob(::File.join(directory, '**', "*.#{provider}")).each do |file|
        logger.debug("Merging system configurations from: #{file}")
        if config_data = parse_config_file(file)
          @system_config = Util::Data.merge([ @system_config, config_data ], true, false)
        end
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
