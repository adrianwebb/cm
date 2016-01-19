
module CM
module Resource
class AWS < Nucleon.plugin_class(:CM, :docker_resource)

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    codes :aws_request_failed, :stack_failed

    settings[:tags] ||= {}
    settings[:rollback] ||= true
    settings[:notification_arns] ||= []
    settings[:capabilities] ||= []

    settings[:wait_retry_interval] ||= 5

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
    plan.manifest_config
  end

  #---

  def compute
    @compute ||= init_compute
  end

  #---

  def cf
    @cf ||= init_cloud_formation
  end

  #---

  def key_file(name)
    File.join(plan.key_directory, "#{name}.pem")
  end

  def template_file(name)
    File.join(plan.path, plugin_provider.to_s, "#{name}.template")
  end

  #-----------------------------------------------------------------------------
  # Operations

  def create_resource
    super do |data|
      case template
      when :keypair
        create_keypair(parameters[:Name], data)
      else
        create_stack(id, parameters, data)
      end
    end
  end

  def retrieve_resource
    resource = nil

    case template
    when :keypair
      resource = fetch_keypair(parameters[:Name])
    else
      resource = fetch_stack(id)
    end
    resource
  end

  def update_resource
    super do |data|
      case template
      when :keypair
        update_keypair(parameters[:Name], data)
      else
        update_stack(id, parameters, data)
      end
    end
  end

  def delete_resource
    super do |data|
      case template
      when :keypair
        delete_keypair(parameters[:Name], data)
      else
        delete_stack(id, data)
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
        error('fetch_keypair_failed', { :id => id, :name => name, :message => error.message })
        myself.status = code.aws_request_failed
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
      error('create_keypair_failed', { :id => id, :name => name, :message => error.message })
      myself.status = code.aws_request_failed
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
      error('update_keypair_failed', { :id => id, :name => name, :message => error.message })
      myself.status = code.aws_request_failed
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
      error('delete_keypair_failed', { :id => id, :name => name, :message => error.message })
      myself.status = code.aws_request_failed
    end
  end

  #-----------------------------------------------------------------------------
  # Stack related functionality

  def fetch_stack(name, reset = false)
    if reset || !@stack
      begin
        result = cf.describe_stacks({ 'StackName' => name })
        @stack = result.body['Stacks'].first

      rescue Fog::AWS::CloudFormation::NotFound => error
        @stack = nil
      rescue => error
        error('fetch_stack_failed', { :id => id, :name => name, :message => error.message })
        myself.status = code.aws_request_failed
      end
    end
    @stack
  end

  def create_stack(name, parameters, data)
    begin
      info('create_stack', { :id => id, :name => template })

      cf.create_stack(name, collect_stack_options(name, parameters, true))

      if wait_for_stack(name, ( timeout / settings[:wait_retry_interval] ), settings[:wait_retry_interval])
        collect_stack_data(name, data)
      else
        handle_stack_failure(name)
      end

    rescue => error
      error('create_stack_failed', { :id => id, :name => name, :message => error.message })
      myself.status = code.aws_request_failed
    end
  end

  def update_stack(name, parameters = {}, data)
    begin
      info('update_stack', { :id => id, :name => template })

      cf.update_stack(name, collect_stack_options(name, parameters, false))

      if wait_for_stack(name, ( timeout / settings[:wait_retry_interval] ), settings[:wait_retry_interval])
        collect_stack_data(name, data)
      else
        handle_stack_failure(name)
      end

    rescue Fog::AWS::CloudFormation::NotFound => error
      info('update_stack_updated', { :id => id, :name => name, :message => error.message })
    rescue => error
      error('update_stack_failed', { :id => id, :name => name, :message => error.message })
      myself.status = code.aws_request_failed
    end
  end

  def delete_stack(name, data)
    begin
      info('delete_stack', { :id => id, :name => template })

      cf.delete_stack(name)

      unless wait_for_stack(name, ( timeout / settings[:wait_retry_interval] ), settings[:wait_retry_interval])
        handle_stack_failure(name)
      end

    rescue => error
      error('delete_stack_failed', { :id => id, :name => name, :message => error.message })
      myself.status = code.aws_request_failed
    end
  end

  #---

  def wait_for_stack(name, tries = 100, interval = 5)
    # Statuses current as of: 2016-01-18
    # URL: http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_Stack.html

    success_statuses = [
      'CREATE_COMPLETE',
      'DELETE_COMPLETE',
      'UPDATE_COMPLETE'
    ]
    failure_statuses = [
      'CREATE_FAILED',
      'ROLLBACK_FAILED',
      'ROLLBACK_COMPLETE',
      'DELETE_FAILED',
      'UPDATE_ROLLBACK_FAILED',
      'UPDATE_ROLLBACK_COMPLETE'
    ]
    in_progress_statuses = [
      'CREATE_IN_PROGRESS',
      'ROLLBACK_IN_PROGRESS',
      'DELETE_IN_PROGRESS',
      'UPDATE_IN_PROGRESS',
      'UPDATE_COMPLETE_CLEANUP_IN_PROGRESS',
      'UPDATE_ROLLBACK_IN_PROGRESS',
      'UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS'
    ]

    next_token = nil
    events = {}

    (1..tries).each do |try|
      begin
        if stack = fetch_stack(name, true)
          status = stack['StackStatus']

          # Display listing of recent events
          result = cf.describe_stack_events(name, Nucleon::Util::Data.clean({ 'NextToken' => next_token })).body
          result['StackEvents'].sort {|a, b| a['Timestamp'] <=> b['Timestamp'] }.each do |event|
            event_message = "#{event['Timestamp']} >>[#{event['ResourceType']}(#{event['PhysicalResourceId']})]: "\
                            "#{event['ResourceStatus']}: #{event['ResourceStatusReason']}"
            event_digest = Nucleon.sha1(event_message)

            if event['Timestamp'] > start_time && !events.key?(event_digest)
              info(event_message, { :i18n => false })
              events[event_digest] = true
            end
            next_token = result['NextToken']
          end
          return true if success_statuses.include?(status)
          return false if failure_statuses.include?(status)

        else
          # This should only be hit if we are deleting a stack
          return true
        end
      rescue => error
        error('wait_stack_failed', { :id => id, :name => name, :message => error.message })
        myself.status = code.aws_request_failed
      end
      sleep interval
    end
    # We exhausted our tries waiting for a completion event :-(
    false
  end

  #---

  def collect_stack_options(name, parameters, create = true)
    options = {
      'Parameters' => parameters,
      'Capabilities' => settings[:capabilities]
    }
    if create
      options['Tags'] = settings[:tags]
      options['TimeoutInMinutes'] = ( timeout / 60 )
      options['DisableRollback'] = !settings[:rollback]
      options['NotificationARNs'] = settings[:notification_arns]
    end

    template_file = template_file(template)

    if File.exist?(template_file)
      options['TemplateBody'] = Nucleon::Util::Disk.read(template_file)
    elsif settings[:url]
      options['TemplateURL'] = settings[:url]
    else
      raise 'AWS template JSON string or S3 URL required'
    end
    options
  end

  def collect_stack_data(name, data)
    stack = fetch_stack(name)

    data[:StackId] = stack['StackId']
    data[:StackStatus] = stack['StackStatus']
    data[:StackCreationTime] = stack['CreationTime']
    data[:StackCapabilities] = stack['Capabilities']
    data[:StackDisabledRollback] = stack['DisableRollback']

    stack['Outputs'].each do |output|
      data[output['OutputKey'].to_sym] = output['OutputValue']
    end
  end

  def handle_stack_failure(name)
    stack = fetch_stack(name)
    error('stack_failure', { :id => id, :name => name, :status => stack['StackStatus'] })
    myself.status = code.stack_failed
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
  protected :init_compute

  #---

  def init_cloud_formation
    require 'fog/aws'

    Fog::AWS::CloudFormation.new({
      :region => manifest_config[:aws][:Region],
      :aws_access_key_id => manifest_config[:aws][:AccessKey],
      :aws_secret_access_key => manifest_config[:aws][:SecretAccessKey]
    })
  end
  protected :init_cloud_formation
end
end
end
