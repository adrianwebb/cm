
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
      register_str :cm_file, 'NA'
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
      unless package.use((settings[:cm_file] == 'NA' ? nil : settings[:cm_file]))
        myself.status = package.status
      end
    end
  end
end
end
end
end
