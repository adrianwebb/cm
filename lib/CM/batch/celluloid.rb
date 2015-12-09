
module CM
module Batch
class Celluloid < Nucleon.plugin_class(:CM, :batch)

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

  #-----------------------------------------------------------------------------
  # Utilities

  def execute_parallel
    values = []
    jobs.each do |job|
      values << Celluloid::Future.new(job) do
        job.execute(sequence.settings)
      end
    end
    values = values.map { |future| future.value }
    !values.include?(false)
  end
end
end
end
