
nucleon_require(File.dirname(__FILE__), :parallel_base)

#---

module CM
module Plugin
class Job < Nucleon.plugin_class(:nucleon, :parallel_base)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    @sequence = delete(:sequence, nil)

    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    true
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def sequence
    @sequence
  end

  #---

  def settings
    get_hash(:settings)
  end

  #-----------------------------------------------------------------------------
  # Operations

  def execute
    if initialized?
      success = true
      success = yield if block_given?
    else
      success = false
    end
    success
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
