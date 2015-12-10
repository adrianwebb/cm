
module CM
module Plugin
class Function < Nucleon.plugin_class(:nucleon, :base)

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

  def execute(args)
    if initialized?
      output = ''
      output = yield if block_given?
    else
      output = ''
    end
    output.strip
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
