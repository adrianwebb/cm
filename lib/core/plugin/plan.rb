
nucleon_require(File.dirname(__FILE__), :parallel_base)

#---

module CM
module Plugin
class Plan < Nucleon.plugin_class(:nucleon, :parallel_base)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super
    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    true
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def directory
    get(:directory, Dir.pwd)
  end

  def key_directory
    get(:key_directory, Dir.pwd)
  end

  #---

  def manifest
    get(:manifest, 'plan.yml')
  end

  #-----------------------------------------------------------------------------
  # Operations

  def execute(operation, options = {})
    method = "operation_#{operation}"
    send(method, options) if respond_to?(method)
  end

  #---

  def operation_deploy(options)
    config = Nucleon::Config.ensure(options)

  end

  #---

  def operation_destroy(options)
    config = Nucleon::Config.ensure(options)

  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
