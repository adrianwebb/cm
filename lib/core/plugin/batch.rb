
module CM
module Plugin
class Batch < Nucleon.plugin_class(:nucleon, :base)

  def self.register_ids
    [ :id ]
  end

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    codes :batch_failed

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

  #---

  def id
    get(:id).to_sym
  end

  #---

  def quit
    @quit
  end

  def quit=quit
    @quit = quit
  end

  #-----------------------------------------------------------------------------
  # Operations

  def execute(operation)
    if initialized?
      myself.status = code.success

      if Nucleon.parallel?
        success = execute_parallel(operation)
      else
        success = execute_sequence(operation)
      end
    else
      success = false
    end
    myself.status = code.batch_failed unless success
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
      resource.execute(operation)
      success = false unless resource.status == code.success

      myself.quit = resource.quit ||
        ((resource.plugin_type != :sequence || resource.plugin_provider != :variables) &&
        plan.trap && plan.step)
      break if quit
    end
    success
  end
end
end
end
