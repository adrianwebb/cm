
nucleon_require(File.dirname(__FILE__), :parallel_base)

#---

module CM
module Plugin
class Job < Nucleon.plugin_class(:nucleon, :parallel_base)

  def self.register_ids
    [ :id ]
  end

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    unless reload
      @sequence = delete(:sequence, nil)
      init_tokens if sequence
    end

    yield if block_given?
  end

  #---

  def init_tokens
    @tokens = {}

    collect_tokens = lambda do |local_settings, token|
      local_settings.each do |name, value|
        setting_token = [ array(token), name ].flatten

        if value.is_a?(Hash)
          collect_tokens.call(value, setting_token)
        else
          token_base = setting_token.shift
          sequence.set_token(token_base, setting_token, value)
        end
      end
    end

    # Generate parameter tokens
    collect_tokens.call(settings[:parameters], id)
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

  #---

  def id
    get(:id, '')
  end

  def parameters
    hash(settings[:parameters])
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
