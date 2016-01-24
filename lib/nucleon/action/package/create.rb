
module Nucleon
module Action
module Package
class Create < Nucleon.plugin_class(:nucleon, :package_action)

  #-----------------------------------------------------------------------------
  # Info

  def self.describe
    super(:package, :create, 1001)
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
      unless package.create
        myself.status = package.status
      end
    end
  end
end
end
end
end
