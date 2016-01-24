
module CM
module Package
class Default < Nucleon.plugin_class(:CM, :package)

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

  #-----------------------------------------------------------------------------
  # Operations

  def create
    super do |success|
      info('create', { :name => plugin_name, :type => plugin_provider, :path => path })

      # Write config file
      if !File.exist?(config_file)
        info('create_config', { :file => config_file })

        Nucleon::Util::Disk.write(config_file, Nucleon::Util::Data.to_yaml({
          :plan_provider => 'default',
          :plan_path => File.join('~', '.cm', plugin_name, 'plan'),
          :manifest => 'manifest.yaml',
          :config_provider => 'file',
          :config_path => File.join('~', '.cm', plugin_name, 'config'),
          :token_provider => 'file',
          :token_path => File.join('~', '.cm', plugin_name, 'config'),
          :token_file => 'tokens.json',
          :key_path => File.join('~', '.cm', plugin_name, 'keys')
        }))
      end

      # Write manifest file
      if !File.exist?(manifest_file)
        info('create_manifest', { :file => manifest_file })

        manifest_content = Nucleon::Util::Disk.read(File.join(templates_path, 'manifest.yaml'))
        Nucleon::Util::Disk.write(manifest_file, manifest_content)
      end

      # Write manifest config file
      if !File.exist?(manifest_config_file)
        info('create_manifest_config', { :file => manifest_config_file })

        config_content = Nucleon::Util::Disk.read(File.join(templates_path, 'config.yaml'))
        Nucleon::Util::Disk.write(manifest_config_file, config_content)
      end
      success
    end
  end

  #---

  def remove
    super do |success|
      info('remove', { :name => plugin_name, :type => plugin_provider, :path => path })

      # Delete config file
      if File.exist?(config_file)
        info('delete_config', { :file => config_file })
        File.delete(config_file)
      end

      # Delete manifest file
      if File.exist?(manifest_file)
        info('delete_manifest', { :file => manifest_file })
        File.delete(manifest_file)
      end

      # Delete manifest config file
      if File.exist?(manifest_config_file)
        info('delete_manifest_config', { :file => manifest_config_file })
        File.delete(manifest_config_file)
      end
      success
    end
  end

  #---

  def install
    super do |success|
      info('install', { :name => plugin_name, :type => plugin_provider, :path => path })
      true
    end
  end

  #---

  def use
    super do |success|
      info('use', { :name => plugin_name, :type => plugin_provider, :path => path })
      true
    end
  end

  #---

  def release
    super do |success|
      info('release', { :name => plugin_name, :type => plugin_provider, :path => path })
      true
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
