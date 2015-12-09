
nucleon_require(File.dirname(__FILE__), :parallel_base)

#---

module CM
module Plugin
class Batch < Nucleon.plugin_class(:nucleon, :parallel_base)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    @sequence = delete(:sequence, nil)

    init_jobs
    yield if block_given?
  end

  #---

  def init_jobs
    @jobs = []
    get_array(:jobs).each do |job_config|
      if job_config.has_key?(:sequence) # Array
        @jobs << sequence.create_sequence(job_config[:sequence])
      else # Atomic
        @jobs << sequence.create_job(job_config)
      end
    end
    @jobs
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

  def jobs
    @jobs
  end

  def jobs=jobs
    set(:jobs, array(jobs))
    init_jobs
  end

  #-----------------------------------------------------------------------------
  # Operations

  def execute(settings, parallel = true)
    if initialized?
      if Nucleon.parallel? && parallel
        success = execute_parallel
      else
        success = execute_sequence
      end
    else
      success = false
    end
    success
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def execute_parallel
    false # Override me!!
  end

  #---

  def execute_sequence
    success = true
    jobs.each do |job|
      success = false unless job.execute(sequence.settings)
    end
    success
  end
end
end
end
