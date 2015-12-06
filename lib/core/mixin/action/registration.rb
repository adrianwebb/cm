
module Nucleon
module Mixin
module Action
module Registration

  #-----------------------------------------------------------------------------
  # Registration definitions

  def register_plan_provider(name, default = nil, locale = nil, &code)
    register_plugin_provider(:CM, :plan, name.to_sym, default, locale, &code)
  end

  #---

  def register_plan_providers(name, default = nil, locale = nil, &code)
    register_plugin_providers(:CM, :plan, name.to_sym, default, locale, &code)
  end

  #---

  def register_plan(name, default = nil, locale = nil, &code)
    register_plugin(:CM, :plan, name.to_sym, default, locale, &code)
  end

  #---

  def register_plans(name, default = nil, locale = nil, &code)
    register_plugins(:CM, :plan, name.to_sym, default, locale, &code)
  end

  #---

  def register_configuration_provider(name, default = nil, locale = nil, &code)
    register_plugin_provider(:CM, :configuration, name.to_sym, default, locale, &code)
  end

  #---

  def register_configuration_providers(name, default = nil, locale = nil, &code)
    register_plugin_providers(:CM, :configuration, name.to_sym, default, locale, &code)
  end

  #---

  def register_configuration(name, default = nil, locale = nil, &code)
    register_plugin(:CM, :configuration, name.to_sym, default, locale, &code)
  end

  #---

  def register_configurations(name, default = nil, locale = nil, &code)
    register_plugins(:CM, :configuration, name.to_sym, default, locale, &code)
  end

  #---

  def register_sequence_provider(name, default = nil, locale = nil, &code)
    register_plugin_provider(:CM, :sequence, name.to_sym, default, locale, &code)
  end

  #---

  def register_sequence_providers(name, default = nil, locale = nil, &code)
    register_plugin_providers(:CM, :sequence, name.to_sym, default, locale, &code)
  end

  #---

  def register_sequence(name, default = nil, locale = nil, &code)
    register_plugin(:CM, :sequence, name.to_sym, default, locale, &code)
  end

  #---

  def register_sequences(name, default = nil, locale = nil, &code)
    register_plugins(:CM, :sequence, name.to_sym, default, locale, &code)
  end

  #---

  def register_batch_provider(name, default = nil, locale = nil, &code)
    register_plugin_provider(:CM, :batch, name.to_sym, default, locale, &code)
  end

  #---

  def register_batch_providers(name, default = nil, locale = nil, &code)
    register_plugin_providers(:CM, :batch, name.to_sym, default, locale, &code)
  end

  #---

  def register_batch(name, default = nil, locale = nil, &code)
    register_plugin(:CM, :batch, name.to_sym, default, locale, &code)
  end

  #---

  def register_batches(name, default = nil, locale = nil, &code)
    register_plugins(:CM, :batch, name.to_sym, default, locale, &code)
  end

  #---

  def register_job_provider(name, default = nil, locale = nil, &code)
    register_plugin_provider(:CM, :jobch, name.to_sym, default, locale, &code)
  end

  #---

  def register_job_providers(name, default = nil, locale = nil, &code)
    register_plugin_providers(:CM, :job, name.to_sym, default, locale, &code)
  end

  #---

  def register_job(name, default = nil, locale = nil, &code)
    register_plugin(:CM, :job, name.to_sym, default, locale, &code)
  end

  #---

  def register_jobs(name, default = nil, locale = nil, &code)
    register_plugins(:CM, :job, name.to_sym, default, locale, &code)
  end
end
end
end
end

