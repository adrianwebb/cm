
nucleon_require(File.dirname(__FILE__), :parallel_base)

#---

module CM
module Plugin
class Plan < Nucleon.plugin_class(:nucleon, :parallel_base)

  include Nucleon::Mixin::SubConfig

  #---

  def self.register_ids
    [ :name, :directory ]
  end

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    logger.debug("Initializing source sub configuration")
    init_subconfig(true) unless reload

    @project = Nucleon.project(extended_config(:plan_project, {
      :provider       => _get(:project_provider, Nucleon.type_default(:nucleon, :project)),
      :directory      => _get(:directory, Dir.pwd),
      :url            => _get(:url),
      :revision       => _get(:revision, :master),
      :create         => true,
      :pull           => true,
      :nucleon_resave => false,
      :nucleon_cache  => false,
      :nucleon_file   => false
    }))

    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    true
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def project
    @project
  end

  #---

  def directory
    project.directory
  end

  def key_directory
    _get(:key_directory, Dir.pwd)
  end

  #---

  def manifest
    _get(:manifest, 'plan.yml')
  end

  def manifest_path
    File.join(directory, manifest)
  end

  #---

  def url
    project.url
  end

  def revision
    project.revision
  end

  #-----------------------------------------------------------------------------
  # Operations

  def execute(operation, options = {})
    success = true

    if File.exist?(manifest_path)
      method = "operation_#{operation}"
      success = send(method, options) if respond_to?(method) && load
    else
      error('manifest_file', { :file => manifest_path })
      success = false
    end
    success
  end

  #---

  def operation_deploy(options)
    config = Nucleon::Config.ensure(options)

  end

  #---

  def operation_destroy(options)
    config = Nucleon::Config.ensure(options)

  end

  #-----------------------------------------------------------------------------
  # Utilities

  def load
    success = false
    if config_data = parse_manifest_file(manifest_path)
      import(config_data, { :force => true, :basic => false })
      success = true
    end
    success
  end

  #---

  def save
    save_manifest_config(manifest_path, export)
  end

  #---

  def parse_manifest_file(file)
    begin
      provider   = File.extname(file).sub(/^\./, '')
      translator = Nucleon.translator({}, provider) if provider
      raise render_message('translator', { :provider => provider, :file => file }) unless translator
      config_data = translator.parse(Nucleon::Util::Disk.read(file))
    rescue => error
      error('config_file', { :file => file })
      error(error.message, { :i18n => false })
      config_data = nil
    end
    config_data
  end
  protected :parse_manifest_file

  #---

  def save_manifest_config(file, properties)
    begin
      provider   = File.extname(file).sub(/^\./, '')
      translator = Nucleon.translator({}, provider) if provider
      raise render_message('translator', { :provider => provider, :file => file }) unless translator
      success = Nucleon::Util::Disk.write(file, translator.generate(properties))
    rescue => error
      error('config_file', { :file => file })
      error(error.message, { :i18n => false })
      success = false
    end
    success
  end
  protected :save_manifest_config
end
end
end
