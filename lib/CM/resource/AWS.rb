
module CM
module Resource
class AWS < Nucleon.plugin_class(:CM, :docker_resource)

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

  def template
    settings[:template]
  end

  #-----------------------------------------------------------------------------
  # Operations

  def operation_deploy
    super do
      require 'fog/aws'

      if template.to_sym == :keypair
        info('deploy_keypair', { :id => id, :name => parameters[:Name], :prefix => false })
      else
        info('deploy_cloudformation', { :id => id, :prefix => false })
      end

      manifest_config = plan.manifest_config

      dbg(manifest_config, 'manifest config')
      dbg(manifest_config[:aws][:AccessKey], 'aws access key')
      dbg(manifest_config[:aws][:SecretAccessKey], 'aws secret access key')
      dbg(manifest_config[:aws][:Region], 'aws region')

      #compute = Fog::Compute.new({
      #  :provider => 'AWS',
      #  :region => manifest_config[:aws][:AccessKey],
      #  :aws_access_key_id => manifest_config[:aws][:SecretAccessKey],
      #  :aws_secret_access_key => manifest_config[:aws][:Region]
      #})


      data = {}
    end
  end

  #---

  def operation_destroy
    super do
      if template.to_sym == :keypair
        info('destroy_keypair', { :id => id, :name => parameters[:Name], :prefix => false })
      else
        info('destroy_cloudformation', { :id => id, :prefix => false })
      end
      data = {}
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities

end
end
end
