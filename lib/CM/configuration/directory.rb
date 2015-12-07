
module CM
module Configuration
class Directory < Nucleon.plugin_class(:CM, :disk_configuration)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super
    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    ::File.directory?(path)
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def output_file
    _get(:output_file, 'rendered.config.yaml')
  end

  def target_path
    ::File.join(path, output_file)
  end

  #-----------------------------------------------------------------------------
  # Operations

  def parse(wipe = true)
    super do
      import_directory(path)
    end
  end

  #---

  def save
    super do
      save_config(target_path, export)
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def import_directory(directory, force = true, deep_merge = true)
    success = true

    Nucleon.loaded_plugins(:nucleon, :translator).each do |provider, info|
      Dir.glob(::File.join(directory, '**', "*.#{provider}")).each do |file|
        logger.debug("Merging configurations from: #{file}")
        if config_data = parse_config(file)
          import(config_data, { :force => force, :basic => !deep_merge })
        else
          success = false
        end
      end
    end
    success
  end
  protected :import_directory
end
end
end
