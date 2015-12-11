
nucleon_require(File.dirname(__FILE__), :parallel_base)

#---

module CM
module Plugin
class Sequence < Nucleon.plugin_class(:nucleon, :parallel_base)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    @plan = delete(:plan, nil) unless reload

    init_jobs
    yield if block_given?
  end

  #---

  def init_jobs
    @jobs = []
    get_array(:jobs).each do |job_config|
      if job_config.has_key?(:aggregate) # Array
        @jobs << plan.create_batch(job_config[:aggregate])
      else # Atomic
        @jobs << plan.create_job(job_config)
      end
    end
    @jobs
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    !@jobs.empty?
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def plan
    @plan
  end

  #---

  def settings
    get_hash(:settings)
  end

  #---

  def jobs
    @jobs
  end

  def jobs=jobs
    set(:jobs, Nucleon::Util::Data.array(jobs))
    init_jobs
  end

  #-----------------------------------------------------------------------------
  # Operations

  def forward(options)
    config = Nucleon::Config.ensure(options)

    if initialized?
      success = true
      success = yield(config, success) if block_given?
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
      success = yield(config, success) if block_given?
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
