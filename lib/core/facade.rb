
module CM
module Facade

  #-----------------------------------------------------------------------------
  # Configuration settings

  def config_path
    ENV['CM_CONFIG_PATH'] || '/etc/cm'
  end

  #-----------------------------------------------------------------------------
  # Core plugin type facade

  def plan(name, options = {}, provider = nil)
    Nucleon.plugin(:CM, :plan, provider, Nucleon::Config.ensure(options).import({ :name => name }))
  end

  def plans(data, build_hash = false, keep_array = false)
    Nucleon.plugins(:CM, :plan, data, build_hash, keep_array)
  end

  #---

  def configuration(options, provider = nil)
    Nucleon.plugin(:CM, :configuration, provider, options)
  end

  def configurations(data, build_hash = false, keep_array = false)
    Nucleon.plugins(:CM, :configuration, data, build_hash, keep_array)
  end

  #-----------------------------------------------------------------------------
  # Processor plugin type facade

  #---

  def sequence(options = {}, provider = nil)
    Nucleon.plugin(:CM, :sequence, provider, options)
  end

  def sequences(data, build_hash = false, keep_array = false)
    Nucleon.plugins(:CM, :sequence, data, build_hash, keep_array)
  end

  #---

  def batch(options, provider = nil)
    Nucleon.plugin(:CM, :batch, provider, options)
  end

  def batches(data, build_hash = false, keep_array = false)
    Nucleon.plugins(:CM, :batch, data, build_hash, keep_array)
  end

  #---

  def resource(options, provider = nil)
    Nucleon.plugin(:CM, :resource, provider, options)
  end

  def resources(data, build_hash = false, keep_array = false)
    Nucleon.plugins(:CM, :resource, data, build_hash, keep_array)
  end

  #---

  def function(options, provider = nil)
    Nucleon.plugin(:CM, :function, provider, options)
  end

  def functions(data, build_hash = false, keep_array = false)
    Nucleon.plugins(:CM, :function, data, build_hash, keep_array)
  end
end
end
