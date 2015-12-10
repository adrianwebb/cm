
nucleon_require(File.dirname(__FILE__), :parallel_base)

#---

module CM
module Plugin
class Sequence < Nucleon.plugin_class(:nucleon, :parallel_base)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    init_tokens
    init_jobs

    yield if block_given?
  end

  #---

  def init_jobs
    @jobs = []
    get_array(:jobs).each do |job_config|
      if job_config.has_key?(:aggregate) # Array
        @jobs << create_batch(job_config[:aggregate])
      else # Atomic
        @jobs << create_job(job_config)
      end
    end
    @jobs
  end

  #---

  def init_tokens
    clear_tokens

    collect_tokens = lambda do |local_settings, token|
      local_settings.each do |name, value|
        setting_token = [ array(token), name ].flatten

        if value.is_a?(Hash)
          collect_tokens.call(value, setting_token)
        else
          token_base = setting_token.shift
          set_token(token_base, setting_token, value)
        end
      end
    end

    # Generate config tokens
    collect_tokens.call(settings, 'config')
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    !@jobs.empty?
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def settings
    get_hash(:settings)
  end

  #---

  def tokens
    @tokens
  end

  def set_token(id, location, value)
    @tokens["#{id}:#{array(location).join('.')}"] = value
  end

  def remove_token(id, location)
    @tokens.delete("#{id}:#{array(location).join('.')}")
  end

  def clear_tokens
    @tokens = {}
  end

  #---

  def jobs
    @jobs
  end

  def jobs=jobs
    set(:jobs, Nucleon::Util::Data.array(jobs))
    init_jobs
    init_tokens
  end

  #---

  def trap
    get(:trap, false)
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

  def step
    answer = ask('Continue? (yes|no): ', { :i18n => false })
    answer.match(/^[Yy][Ee][Ss]$/) ? false : true
  end

  #---

  def create_sequence(jobs)
    CM.sequence({
      :settings => settings,
      :jobs => jobs,
      :trap => trap,
      :new => true,
    }, get(:sequence_provider, :default))
  end

  #---

  def create_batch(jobs)
    CM.batch({
      :sequence => myself,
      :jobs => jobs,
      :new => true
    }, get(:batch_provider, :celluloid))
  end

  #---

  def create_job(settings)
    settings[:type] ||= get(:default_job_provider, :variables)
    CM.job({
      :sequence => myself,
      :settings => settings,
      :id => settings[:name]
    }, settings[:type])
  end
end
end
end
