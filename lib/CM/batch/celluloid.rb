
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

  def execute_parallel(operation)
    values = []
    timeouts = []

    resources.each do |resource|
      values << ::Celluloid::Future.new(resource) do
        success = true
        begin
          timeouts << ( resource.respond_to?(:timeout) ? resource.timeout : nil )

          resource.execute(operation)
          success = resource.status == code.success

        rescue => error
          logger.error("Resource #{resource.id} #{operation} experienced an error:")
          logger.error(error.inspect)
          logger.error(error.message)
          logger.error(Nucleon::Util::Data.to_yaml(error.backtrace))

          error('resource_execution', { :id => resource.id, :operation => operation, :message => error.message })
          success = false
        end
        success
      end
    end
    values = values.each_with_index.map do |future, index|
      future.value(timeouts[index])
    end
    !values.include?(false)
  end
end
end
end
