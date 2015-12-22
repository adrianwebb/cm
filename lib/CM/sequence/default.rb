
module CM
module Sequence
class Default < Nucleon.plugin_class(:CM, :sequence)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super
    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  #-----------------------------------------------------------------------------
  # Operations

  def forward(operation)
    super do |success|
      resources.each do |resource|
        success = false unless resource.execute(operation)
        break if plan.trap && plan.step
      end
      success
    end
  end

  #---

  def reverse(operation)
    super do |success|
      resources.reverse.each do |resource|
        success = false unless resource.execute(operation)
        break if plan.trap && plan.step
      end
      success
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
