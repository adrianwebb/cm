
module CM
module Resource
class AWS < Nucleon.plugin_class(:CM, :docker_resource)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    codes :aws_request_failed

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
    settings[:template].to_sym
  end

  #---

  def manifest_config
    @manifest_config ||= plan.manifest_config
  end

  #---

  def compute
    @compute ||= init_compute
  end

  #---

  def key_file(name)
    File.join(plan.key_directory, "#{name}.pem")
  end

  #-----------------------------------------------------------------------------
  # Operations

  def create_resource
    super do |data|
      if template == :keypair
        create_keypair(parameters[:Name], data)
      else
        #info('create_stack', { :id => id, :name => template, :prefix => false })
        #create_stack(template, parameters, data)
      end
    end
  end

  def retrieve_resource
    resource = nil
    if template == :keypair
      resource = fetch_keypair(parameters[:Name])
    else
      #resource = fetch_stack(template)
      #dbg(resource, 'retrieval results')
    end
    resource
  end

  def update_resource
    super do |data|
      if template == :keypair
        update_keypair(parameters[:Name], data)
      else
        #info('update_stack', { :id => id, :name => template, :prefix => false })
        #update_stack(template, parameters, data)
      end
    end
  end

  def delete_resource
    super do |data|
      if template == :keypair
        delete_keypair(parameters[:Name], data)
      else
        #info('delete_stack', { :id => id, :name => template, :prefix => false })
        #delete_stack(template, data)
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Keypair related functionality

  def fetch_keypair(name, reset = false)
    if reset || !@keypair
      begin
        aws_keypair = nil

        result = compute.describe_key_pairs({ 'key-name' => [name] })
        aws_keypair = result.body['keySet'].first['keyFingerprint'] if result.body['keySet'].length == 1

        if aws_keypair
          @keypair = {
            :name => name.to_sym,
            :fingerprint => aws_keypair,
            :file => key_file(name)
          }
        end
      rescue => error
        # Placeholder for logging in the future
        raise error
      end
    end
    @keypair
  end

  def create_keypair(name, data, suppress_info = false)
    begin
      info('create_keypair', { :id => id, :name => parameters[:Name] }) unless suppress_info

      private_key_file = key_file(name)
      result = compute.create_key_pair(name)

      Nucleon::Util::Disk.write(private_key_file, result.body['keyMaterial'])
      FileUtils.chmod(0600, private_key_file)

      aws_keypair = fetch_keypair(name, true)
      data[:Fingerprint] = aws_keypair[:fingerprint]
      data[:Content] = result.body['keyMaterial']
      data[:File] = aws_keypair[:file]

    rescue => error
      myself.status = code.aws_request_failed
      raise error
    end
  end

  def update_keypair(name, data)
    begin
      info('check_keypair', { :id => id, :name => parameters[:Name] })

      aws_keypair = fetch_keypair(name)
      private_key_file = aws_keypair[:file]
      update = false

      if File.exist?(private_key_file)
        local_keypair = `openssl pkcs8 -in #{private_key_file} -inform PEM -outform DER -topk8 -nocrypt | openssl sha1 -c`.strip.sub(/^[^\s]+\s+/, '')

        if aws_keypair[:fingerprint] != local_keypair
          File.delete(private_key_file)
          update = true
        end
      else
        update = true
      end

      if update
        info('update_keypair', { :id => id, :name => parameters[:Name] })

        compute.delete_key_pair(name)
        create_keypair(name, data, true)
      end
    rescue => error
      myself.status = code.aws_request_failed
      raise error
    end
  end

  def delete_keypair(name, data)
    begin
      info('delete_keypair', { :id => id, :name => parameters[:Name] })

      if aws_keypair = fetch_keypair(name)
        result = compute.delete_key_pair(name)
        File.delete(aws_keypair[:file]) if File.exist?(aws_keypair[:file])
      end
    rescue => error
      myself.status = code.aws_request_failed
      raise error
    end
  end

  #-----------------------------------------------------------------------------
  # Stack related functionality

  def fetch_stack(name, data)

  end

  def create_stack(name, parameters = {}, data)

  end

  def update_stack(name, parameters = {}, data)

  end

  def delete_stack(name, data)

  end

  #-----------------------------------------------------------------------------
  # Utilities

  def init_compute
    require 'fog/aws'

    Fog::Compute.new({
      :provider => 'AWS',
      :region => manifest_config[:aws][:Region],
      :aws_access_key_id => manifest_config[:aws][:AccessKey],
      :aws_secret_access_key => manifest_config[:aws][:SecretAccessKey]
    })
  end
end
end
end
