
module CM
module Plugin
class Package < Nucleon.plugin_class(:CM, :disk_configuration)

  include Nucleon::Parallel  # All sub providers are parallel capable

  #-----------------------------------------------------------------------------

  def self.register_ids
    [ :name, :path ]
  end

  def self.options(action)
    # Override if needed
  end

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    initialize_package

    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    Dir.exist?(path)
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def action_settings
    _get(:action_settings, {})
  end

  #---

  def path
    _get(:path, Dir.pwd)
  end

  def config_file
    File.join(path, 'config.yaml')
  end

  def plan_path
    File.join(path, 'plan')
  end

  def manifest_file
    File.join(plan_path, 'manifest.yaml')
  end

  def config_path
    File.join(path, 'config')
  end

  def manifest_config_file
    File.join(config_path, 'config.yaml')
  end

  def key_path
    File.join(path, 'keys')
  end

  def cert_path
    File.join(path, 'certs')
  end

  #---

  def templates_path
    File.join(CM.lib_path, '..', 'templates')
  end

  #-----------------------------------------------------------------------------
  # Operations

  def create
    success = true
    myself.status = code.success

    codes :package_create_failed,
          :package_create_error

    begin
      success = initialize_package
      success = yield(success) if success && block_given?
      myself.status = code.package_create_failed if !success && status == code.success

    rescue => error
      error('create_failed', { :message => error.message })
      myself.status = code.package_create_error
      success = false
    end
    success
  end

  #---

  def remove
    success = true
    myself.status = code.success

    codes :package_remove_failed,
          :package_remove_not_initialized,
          :package_remove_error

    begin
      if initialized?
        success = yield(success) if block_given?
        success = remove_package if success
        myself.status = code.package_remove_failed if !success && status == code.success
      else
        myself.status = code.package_remove_not_initialized
        success = false
      end

    rescue => error
      error('remove_failed', { :message => error.message })
      myself.status = code.package_remove_error
      success = false
    end
    success
  end

  #---

  def install
    success = true
    myself.status = code.success

    codes :package_install_failed,
          :package_install_error

    begin
      success = yield(success) if block_given?
      myself.status = code.package_install_failed if !success && status == code.success

    rescue => error
      error('install_failed', { :message => error.message })
      myself.status = code.package_install_error
      success = false
    end
    success
  end

  #---

  def use
    success = true
    myself.status = code.success

    codes :package_use_failed,
          :package_use_not_initialized,
          :package_use_error

    begin
      if initialized?
        success = yield(success) if block_given?
        myself.status = code.package_use_failed if !success && status == code.success
      else
        myself.status = code.package_use_not_initialized
        success = false
      end

    rescue => error
      error('use_failed', { :message => error.message })
      myself.status = code.package_use_error
      success = false
    end
    success
  end

  #---

  def release
    success = true
    myself.status = code.success

    codes :package_release_failed,
          :package_release_not_initialized,
          :package_release_error

    begin
      if initialized?
        success = yield(success) if block_given?
        myself.status = code.package_release_failed if !success && status == code.success
      else
        myself.status = code.package_release_not_initialized
        success = false
      end

    rescue => error
      error('release_failed', { :message => error.message })
      myself.status = code.package_release_error
      success = false
    end
    success
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def initialize_package
    success = true

    begin
      ensure_directory(path)
      ensure_directory(plan_path)
      ensure_directory(config_path)
      ensure_directory(key_path)
      ensure_directory(cert_path)

      # Creating additional registered resource plugin directories
      Nucleon.loaded_plugins(:CM, :resource).each do |provider, data|
        if data[:class].project_directory?
          ensure_directory(File.join(plan_path, provider.to_s))
        end
      end

    rescue => error
      error('initialize_failed', { :message => error.message })
      success = false
    end
    success
  end

  #---

  def remove_package
    success = true

    begin
      # Deleting additional registered resource plugin directories
      Nucleon.loaded_plugins(:CM, :resource).each do |provider, data|
        if data[:class].project_directory?
          remove_directory(File.join(plan_path, provider.to_s))
        end
      end

      remove_directory(key_path)
      remove_directory(cert_path)
      remove_directory(config_path)
      remove_directory(plan_path)
      remove_directory(path)

    rescue => error
      error('remove_failed', { :message => error.message })
      success = false
    end
    success
  end

  #---

  def ensure_directory(path)
    FileUtils.mkdir_p(path)
  end

  def remove_directory(path)
    # TODO: Revisit this rm -Rf decision.
    # Could this be done with just an empty directory delete
    #  afer all children have cleaned up?
    FileUtils.rm_rf(path)
  end
end
end
end
