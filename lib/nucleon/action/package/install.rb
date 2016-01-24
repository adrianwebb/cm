
module Nucleon
module Action
module Package
class Install < Nucleon.plugin_class(:nucleon, :package_action)

  #-----------------------------------------------------------------------------
  # Info

  def self.describe
    super(:package, :install, 1000)
  end

  #-----------------------------------------------------------------------------
  # Settings

  def configure
    super do

    end
  end

  #-----------------------------------------------------------------------------
  # Action operations

  def execute
    super do
      info('start')
      unless package.install
        myself.status = package.status
      end
    end
  end
end
end
end
end
