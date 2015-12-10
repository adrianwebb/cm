
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

  def forward(options)
    super do |config, success|
      jobs.each do |job|
        success = false unless job.execute
      end
      success
    end
  end

  #---

  def reverse(options)
    super do |config, success|
      jobs.reverse.each do |job|
        success = false unless job.execute
      end
      success
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
