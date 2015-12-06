
module CM
module Facade

  #-----------------------------------------------------------------------------
  # Configuration settings

  def config_dir
    ENV['CM_CONFIG_DIR'] || '/etc/cm'
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

  def sequence(data, build_hash = false, keep_array = false)
    Nucleon.plugins(:CM, :sequence, data, build_hash, keep_array)
  end

  #---

  def batch(options, provider = nil)
    Nucleon.plugin(:CM, :batch, provider, options)
  end

  def batch(data, build_hash = false, keep_array = false)
    Nucleon.plugins(:CM, :batch, data, build_hash, keep_array)
  end

  #---

  def job(options, provider = nil)
    Nucleon.plugin(:CM, :job, provider, options)
  end

  def jobs(data, build_hash = false, keep_array = false)
    Nucleon.plugins(:CM, :job, data, build_hash, keep_array)
  end
end
end
