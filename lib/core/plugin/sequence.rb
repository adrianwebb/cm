
nucleon_require(File.dirname(__FILE__), :parallel_base)

#---

module CM
module Plugin
class Sequence < Nucleon.plugin_class(:nucleon, :parallel_base)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
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

  #-----------------------------------------------------------------------------
  # Operations

  def forward(options)
    config = Nucleon::Config.ensure(options)

    if initialized?
      success = true
      success = yield(config) if block_given?
    else
      success = false
    end
    success
  end

  #---

  def reverse(options)
    config = Nucleon::Config.ensure(options)

    if initialized?
      success = true
      success = yield(config) if block_given?
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
