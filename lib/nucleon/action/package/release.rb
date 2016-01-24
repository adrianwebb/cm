
module Nucleon
module Action
module Package
class Release < Nucleon.plugin_class(:nucleon, :package_action)

  #-----------------------------------------------------------------------------
  # Info

  def self.describe
    super(:package, :release, 998)
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
      unless package.release
        myself.status = package.status
      end
    end
  end
end
end
end
end
