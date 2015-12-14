
nucleon_require(File.dirname(__FILE__), :parallel_base)

#---

module CM
module Plugin
class Batch < Nucleon.plugin_class(:nucleon, :parallel_base)

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
      if resource_config.has_key?(:sequence) # Array
        @resources << plan.create_sequence(resource_config[:sequence])
      else # Atomic
        @resources << plan.create_resource(resource_config)
      end
    end
    @resources
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    true
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def plan
    @plan
  end

  #---

  def resources
    @resources
  end

  def resources=resources
    set(:resources, array(resources))
    init_resources
  end

  #-----------------------------------------------------------------------------
  # Operations

  def execute(operation)
    if initialized?
      if Nucleon.parallel?
        success = execute_parallel(operation)
      else
        success = execute_sequence(operation)
      end
    else
      success = false
    end
    success
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def execute_parallel(operation)
    false # Override me!!
  end

  #---

  def execute_sequence(operation)
    success = true
    resources.each do |resource|
      success = false unless resource.execute(operation)
      break if plan.trap && plan.step
    end
    success
  end
end
end
end
