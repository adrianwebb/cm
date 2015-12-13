
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

    init_resources
    yield if block_given?
  end

  #---

  def init_resources
    @resources = []
    get_array(:resources).each do |resource_config|
      if resource_config.has_key?(:aggregate) # Array
        @resources << plan.create_batch(resource_config[:aggregate])
      else # Atomic
        @resources << plan.create_resource(resource_config)
      end
    end
    @resources
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    !@resources.empty?
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

  def resources
    @resources
  end

  def resources=resources
    set(:resources, Nucleon::Util::Data.array(resources))
    init_resources
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
