
nucleon_require(File.dirname(__FILE__), :parallel_base)

#---

module CM
module Plugin
class Plan < Nucleon.plugin_class(:nucleon, :parallel_base)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    @project = Nucleon.project(extended_config(:plan_project, {
      :provider       => get(:project_provider, Nucleon.type_default(:nucleon, :project)),
      :directory      => get(:directory, Dir.pwd),
      :url            => get(:url),
      :revision       => get(:revision, :master),
      :create         => true,
      :pull           => true,
      :nucleon_resave => false,
      :nucleon_cache  => false
    }))

    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    true
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def project
    @project
  end

  #---

  def directory
    project.directory
  end

  def key_directory
    get(:key_directory, Dir.pwd)
  end

  #---

  def manifest
    get(:manifest, 'plan.yml')
  end

  def manifest_path
    File.join(directory, manifest)
  end

  #---

  def url
    project.url
  end

  def revision
    project.revision
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
