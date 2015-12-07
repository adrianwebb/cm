
nucleon_require(File.dirname(__FILE__), :configuration)

#---

module CM
module Plugin
class DiskConfiguration < Nucleon.plugin_class(:CM, :configuration)

  def self.register_ids
    [ :name, :path ]
  end

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super
    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def path
    _get(:path)
  end

  #---

  def translator_error
    _get(:translator_error, 'translator')
  end

  def config_error
    _get(:config_error, 'config')
  end

  #-----------------------------------------------------------------------------
  # Operations

  #-----------------------------------------------------------------------------
  # Utilities

  def parse_config(file)
    begin
      provider   = File.extname(file).sub(/^\./, '')
      translator = Nucleon.translator({}, provider) if provider

      raise render_message("#{translator_error}.parse", { :provider => provider, :file => file }) unless translator
      config_data = translator.parse(Nucleon::Util::Disk.read(file))

    rescue => error
      error("#{config_error}.parse", { :file => file })
      error(error.message, { :i18n => false })
      config_data = nil
    end
    config_data
  end
  protected :parse_config

  #---

  def save_config(file, properties)
    begin
      provider   = File.extname(file).sub(/^\./, '')
      properties = Nucleon::Config.ensure(properties).export
      translator = Nucleon.translator({}, provider) if provider

      raise render_message("#{translator_error}.save", { :provider => provider, :file => file }) unless translator
      success = Nucleon::Util::Disk.write(file, translator.generate(properties))

    rescue => error
      error("#{config_error}.save", { :file => file })
      error(error.message, { :i18n => false })
      success = false
    end
    success
  end
  protected :save_config
end
end
end
