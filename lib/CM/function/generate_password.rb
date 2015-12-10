
module CM
module Function
class GeneratePassword < Nucleon.plugin_class(:CM, :function)

  #-----------------------------------------------------------------------------
  # Plugin interface

  #-----------------------------------------------------------------------------
  # Checks

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  #-----------------------------------------------------------------------------
  # Operations

  def execute(args)
    super do
      length = (args.length == 1 ? args[0] : 40)
      `openssl rand -base64 "$((#{length} * 2))" | perl -pe 's/[^a-zA-Z0-9]//g' - | cut -c1-#{length}`
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
