
module CM
module Facade

  #-----------------------------------------------------------------------------
  # Configuration settings

  def config_dir
    ENV['CM_CONFIG_DIR'] || '/etc/cm'
  end

  def config_file
    ENV['CM_CONFIG_FILE'] || 'config.yml'
  end

  def config_path
    "#{config_dir}/#{config_file}"
  end
end
end
