
module Nucleon
module Action
module Package
class Install < Nucleon.plugin_class(:nucleon, :package_action)

  #-----------------------------------------------------------------------------
  # Info

  def self.describe
    super(:package, :install, 1004)
  end

  #-----------------------------------------------------------------------------
  # Settings

  def configure
    super do
      register_file :cm_file, nil
    end
  end

  def arguments
    [ super, :cm_file ].flatten
  end

  #-----------------------------------------------------------------------------
  # Action operations

  def execute
    super do
      info('start')
      unless package.install(settings[:cm_file])
        myself.status = package.status
      end
    end
  end
end
end
end
end
