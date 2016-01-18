
module CM
module Plugin
class Sequence < Nucleon.plugin_class(:nucleon, :base)

  def self.register_ids
    [ :id ]
  end

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    codes :sequence_failed

    @plan = delete(:plan, nil) unless reload

    init_resources
    yield if block_given?
  end

  #---

  def init_resources
    @resources = []
    get_array(:resources).each do |resource_config|
      resource_config = Nucleon::Config.ensure(resource_config)

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
    plan.manifest_config
  end

  #---

  def resources
    @resources
  end

  def resources=resources
    set(:resources, Nucleon::Util::Data.array(resources))
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

  def forward(operation)
    if initialized?
      myself.status = code.success

      success = true
      success = yield(success) if block_given?
    else
      success = false
    end
    myself.status = code.sequence_failed unless success
    success
  end

  #---

  def reverse(operation)
    if initialized?
      myself.status = code.success

      success = true
      success = yield(success) if block_given?
    else
      success = false
    end
    myself.status = code.sequence_failed unless success
    success
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
