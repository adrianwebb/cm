
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
        myself.quit = resource.quit ||
          (((resource.plugin_type == :batch && !Nucleon.parallel?) ||
          resource.plugin_provider != :variables) && plan.trap && plan.step)
        break if quit
      end
      success
    end
  end

  #---

  def reverse(operation)
    super do |success|
      resources.reverse.each do |resource|
        success = false unless resource.execute(operation)
        myself.quit = resource.quit ||
          (((resource.plugin_type == :batch && !Nucleon.parallel?) ||
          resource.plugin_provider != :variables) && plan.trap && plan.step)
        break if quit
      end
      success
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
