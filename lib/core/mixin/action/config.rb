
module Nucleon
module Mixin
module Action
module Config

  #-----------------------------------------------------------------------------
  # Settings

  def config_config
    register_str :config_file, CM.config_path, 'nucleon.mixin.action.config.options.config_file' do |value|
      success = true
      if value
        file = File.expand_path(value)
        # Configuration file exists
        if File.exist?(file)
          # Configuration invalid?
          begin
            provider   = File.extname(file).sub(/^\./, '')
            translator = Nucleon.translator({}, provider) if provider
            raise I18n.t('nucleon.mixin.action.config.errors.translator', { :provider => provider, :file => file }) unless translator
            @config = translator.parse(Util::Disk.read(file))
          rescue => error
            warn(error.message, { :i18n => false })
            @config = nil
          end

          # No configuration available?
          if @config.nil?
            warn('nucleon.mixin.action.config.errors.config_file', { :value => file })
            success = false
          end
        else
          # Non existent configuration file
          warn('nucleon.mixin.action.config.errors.config_file', { :value => file })
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
    @config
  end
end
end
end
end
