
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
      register_str :cm_file, "#{plugin_name}-#{Time.now.strftime('%Y-%m-%dT%H-%M-%S%Z')}.cm"
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
      unless package.release(settings[:cm_file])
        myself.status = package.status
      end
    end
  end
end
end
end
end
