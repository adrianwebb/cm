
module CM
module Configuration
class File < Nucleon.plugin_class(:CM, :disk_configuration)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super
    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    file && ::File.exist?(file)
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  #-----------------------------------------------------------------------------
  # Operations

  def parse(wipe = true)
    super do
      import_file(path)
    end
  end

  #---

  def save
    super do
      save_config(path, export)
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def import_file(file, force = true, deep_merge = true)
    success = true
    if config_data = parse_config(file)
      import(config_data, { :force => force, :basic => !deep_merge })
    else
      success = false
    end
    success
  end
  protected :import_file
end
end
end
