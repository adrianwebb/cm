
nucleon_require(File.dirname(__FILE__), :disk_configuration)

#---

module CM
module Plugin
class Plan < Nucleon.plugin_class(:CM, :disk_configuration)

  def self.register_ids
    [ :directory, :revision ]
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

    if project && !reload
      @loaded_config = CM.configuration(extended_config(:config_data, {
        :provider => _get(:config_provider, :directory),
        :path => config_directory
      }))

      yield if block_given?
    end
  end

  #---

  def init_tokens
    clear_tokens

    collect_tokens = lambda do |local_settings, token|
      local_settings.each do |name, value|
        setting_token = [ array(token), name ].flatten

        if value.is_a?(Hash)
          collect_tokens.call(value, setting_token)
        else
          token_base = setting_token.shift
          set_token(token_base, setting_token, value)
        end
      end
    end

    # Generate config tokens
    collect_tokens.call(manifest_config, 'config')
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

  #---

  def tokens
    @tokens
  end

  def set_token(id, location, value)
    @tokens["#{id}:#{array(location).join('.')}"] = value
  end

  def remove_token(id, location)
    @tokens.delete("#{id}:#{array(location).join('.')}")
  end

  def clear_tokens
    @tokens = {}
  end

  #---

  def trap
    _get(:trap, false)
  end

  #-----------------------------------------------------------------------------
  # Operations

  def load
    success = true

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
      @sequence = create_sequence(manifest_jobs)

      yield if block_given?
    end
    success
  end

  #---

  def execute(operation, options = {})
    success = true

    if initialized?
      if ::File.exist?(manifest_path)
        method = "operation_#{operation}"

        if respond_to?(method) && load
          init_tokens
          success = send(method, options)
        end
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

  def create_sequence(jobs)
    CM.sequence({
      :plan => myself,
      :settings => manifest_config,
      :jobs => jobs,
      :new => true,
    }, _get(:sequence_provider, :default))
  end

  #---

  def create_batch(jobs)
    CM.batch({
      :plan => myself,
      :jobs => jobs,
      :new => true
    }, _get(:batch_provider, :celluloid))
  end

  #---

  def create_job(settings)
    settings[:type] ||= _get(:default_job_provider, :variables)
    CM.job({
      :plan => myself,
      :settings => settings,
      :id => settings[:name]
    }, settings[:type])
  end

  #---

  def step
    answer = ask('Continue? (yes|no): ', { :i18n => false })
    answer.match(/^[Yy][Ee][Ss]$/) ? false : true
  end
end
end
end
