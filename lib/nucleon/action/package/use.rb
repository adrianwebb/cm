
module Nucleon
module Action
module Package
class Use < Nucleon.plugin_class(:nucleon, :package_action)

  #-----------------------------------------------------------------------------
  # Info

  def self.describe
    super(:package, :use, 999)
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
      unless package.use
        myself.status = package.status
      end
    end
  end
end
end
end
end
