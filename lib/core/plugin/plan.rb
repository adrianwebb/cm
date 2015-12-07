
nucleon_require(File.dirname(__FILE__), :disk_configuration)

#---

module CM
module Plugin
class Plan < Nucleon.plugin_class(:CM, :disk_configuration)

  #---

  def self.register_ids
    [ :name, :path ]
  end

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    @project = Nucleon.project(extended_config(:plan_project, {
      :provider       => _get(:project_provider, Nucleon.type_default(:nucleon, :project)),
      :directory      => _get(:path, Dir.pwd),
      :url            => _get(:url),
      :revision       => _get(:revision, :master),
      :create         => true,
      :pull           => true,
      :nucleon_resave => false,
      :nucleon_cache  => false,
      :nucleon_file   => false
    }))

    if project
      @loaded_config = CM.configuration(extended_config(:config_data, {
        :provider => _get(:config_provider, :directory),
        :path => path
      }))

      yield if block_given?
    end
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    project && loaded_config
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def project
    @project
  end

  def loaded_config
    @loaded_config
  end

  #---

  def path
    project.directory
  end

  def key_directory
    _get(:key_directory, path)
  end

  #---

  def manifest_file
    _get(:manifest_file, 'plan.yml')
  end

  def manifest_path
    ::File.join(path, manifest_file)
  end

  def manifest
    export
  end

  def manifest_config
    get_hash(:config)
  end

  def manifest_jobs
    get_array(:jobs)
  end

  #---

  def config_directory
    _get(:config_directory, path)
  end

  def output_file
    _get(:output_file, "rendered.#{manifest_file.gsub(/#{File::SEPARATOR}+/, '.')}")
  end

  def target_path
    ::File.join(config_directory, output_file)
  end


  #---

  def url
    project.url
  end

  def revision
    project.revision
  end

  #---

  def sequence
    @sequence
  end

  #-----------------------------------------------------------------------------
  # Operations

  def load
    if initialized?
      # Initialize plan manifest (default config and jobs)
      wipe
      import(CM.configuration(extended_config(:manifest_data, {
        :provider => _get(:manifest_provider, :file),
        :path => manifest_path
      })).export)

      # Merge in configuration overlay (private config)
      override(loaded_config.get_hash(:config), :config)

      # Initialize job sequence
      @sequence = CM.sequence({
        :jobs => manifest_jobs,
        :config => manifest_config
      }, _get(:sequence_provider, :default))

      yield if block_given?
    end
  end

  #---

  def execute(operation, options = {})
    success = true

    if initialized?
      if ::File.exist?(manifest_path)
        method = "operation_#{operation}"
        success = send(method, options) if respond_to?(method) && load
        success = save if success
        success
      else
        error('manifest_file', { :file => manifest_path })
        success = false
      end
    else
      success = false
    end
    success
  end

  #---

  def operation_deploy(options)
    config = Nucleon::Config.ensure(options)
    sequence.forward(config)
  end

  #---

  def operation_destroy(options)
    config = Nucleon::Config.ensure(options)
    sequence.reverse(config)
  end

  #---

  def save
    save_config(target_path, { :config => manifest_config })
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
