
nucleon_require(File.dirname(__FILE__), :disk_configuration)

#---

module CM
module Plugin
class Plan < Nucleon.plugin_class(:CM, :disk_configuration)

  include Nucleon::Parallel  # All sub providers are parallel capable

  #---

  def self.register_ids
    [ :directory, :revision ]
  end

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    if !reload
      @loaded_config = CM.configuration(extended_config(:config_data, {
        :provider => _get(:config_provider, :directory),
        :path => config_path
      }))

      @tokens = CM.configuration(extended_config(:token_data, {
        :provider => _get(:token_provider, :file),
        :path => token_path
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
    loaded_config
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def loaded_config
    @loaded_config
  end

  #---

  def action_settings
    _get(:action_settings, {})
  end

  #---

  def path
    _get(:path, Dir.pwd)
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

  def manifest_resources
    get_array(:resources)
  end

  #---

  def config_path
    _get(:config_path, path)
  end

  #---

  def sequence
    @sequence
  end

  #---

  def token_directory
    _get(:token_directory, config_path)
  end

  def token_file
    _get(:token_file, 'tokens.json')
  end

  def token_path
    ::File.join(token_directory, token_file)
  end

  #---

  def tokens
    @tokens.parse
  end

  def set_token(id, location, value)
    @tokens["#{id}:#{array(location).join('.')}"] = value
    @tokens.save
  end

  def remove_token(id, location)
    @tokens.delete("#{id}:#{array(location).join('.')}")
    @tokens.save
  end

  def clear_tokens
    @tokens.wipe
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
      # Initialize plan manifest (default config and resources)
      wipe
      import(CM.configuration(extended_config(:manifest_data, {
        :provider => _get(:manifest_provider, :file),
        :path => manifest_path
      })).export)

      # Merge in configuration overlay (private config)
      override(loaded_config.get_hash(:config), :config)

      # Initializeresource sequence
      @sequence = create_sequence(manifest_resources)

      yield if block_given?
    end
    success
  end

  #---

  def execute(operation)
    success = true

    if initialized?
      if ::File.exist?(manifest_path)
        method = "operation_#{operation}"

        if respond_to?(method) && load
          init_tokens
          success = send(method)
        end
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

  def operation_deploy
    sequence.forward(:deploy)
  end

  #---

  def operation_destroy
    sequence.reverse(:destroy)
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def create_sequence(resources)
    CM.sequence({
      :plan => myself,
      :settings => manifest_config,
      :resources => resources,
      :new => true,
    }, _get(:sequence_provider, :default))
  end

  #---

  def create_batch(resources)
    CM.batch({
      :plan => myself,
      :resources => resources,
      :new => true
    }, _get(:batch_provider, :celluloid))
  end

  #---

  def create_resource(settings)
    settings = Nucleon::Config.ensure(settings)
    settings[:type] ||= _get(:default_resource_provider, :variables)

    CM.resource({
      :plan => myself,
      :settings => settings.export,
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
