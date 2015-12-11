
nucleon_require(File.dirname(__FILE__), :job)

#---

module CM
module Plugin
class DockerJob < Nucleon.plugin_class(:CM, :job)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    require 'docker'

    super
    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    true
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def image
    settings[:image]
  end

  def image=image
    settings[:image] = image
  end

  #-----------------------------------------------------------------------------
  # Operations

  def execute
    super do
      success = true
      success = yield if block_given?
      success
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
