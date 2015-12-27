
module CM
module Plugin
class Configuration < Nucleon.plugin_class(:nucleon, :base)

  include Nucleon::Mixin::SubConfig

  #---

  def self.register_ids
    [ :name ]
  end

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    logger.debug("Initializing source sub configuration")
    init_subconfig(true) unless reload

    yield if block_given?
    parse
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

  def wipe
    if initialized?
      clear
      yield if block_given?
    end
  end

  #---

  def parse(wipe = true)
    if initialized?
      clear if wipe
      yield if block_given?
    end
    export
  end

  #---

  def save
    if initialized?
      yield if block_given?
    end
  end

  #---

  def override(properties, keys = nil)
    if initialized?
      if keys.nil?
        import(properties)
      else
        set(keys, Nucleon::Config.new(get(keys), {}, true, false).import(properties).export)
      end
      yield if block_given?
    end
    myself
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
