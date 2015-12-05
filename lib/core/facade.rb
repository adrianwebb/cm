
module CM
module Facade

  #-----------------------------------------------------------------------------
  # Configuration settings

  def config_dir
    ENV['CM_CONFIG_DIR'] || '/etc/cm'
  end
end
end
