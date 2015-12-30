
module CM
module Plugin
class Resource < Nucleon.plugin_class(:nucleon, :base)

  def self.register_ids
    [ :plugin_name, :id ]
  end

  #-----------------------------------------------------------------------------
  # Plugin interface

  def normalize(reload)
    super

    @plan = delete(:plan, nil) unless reload

    yield if block_given?
  end

  #---

  def init_tokens
    collect_tokens = lambda do |local_settings, token|
      local_settings.each do |name, value|
        setting_token = [ array(token), name ].flatten

        if value.is_a?(Hash)
          collect_tokens.call(value, setting_token)
        else
          token_base = setting_token.shift
          plan.set_token(token_base, setting_token, value)
        end
      end
    end

    # Generate parameter tokens
    collect_tokens.call(settings[:parameters], id)
  end

  #-----------------------------------------------------------------------------
  # Checks

  def initialized?(options = {})
    true
  end

  #-----------------------------------------------------------------------------
  # Property accessors / modifiers

  def plan
    @plan
  end

  #---

  def settings
    get_hash(:settings)
  end

  #---

  def id
    get(:id, '').to_sym
  end

  def parameters
    hash(settings[:parameters])
  end

  #---

  def data
    hash(@data)
  end

  def data=data
    @data = hash(data)
  end

  #---

  def quit
    @quit
  end

  def quit=quit
    @quit = quit
  end

  #-----------------------------------------------------------------------------
  # Operations

  def execute(operation)
    if initialized?
      method = "operation_#{operation}"

      myself.status = code.success

      execute_functions
      interpolate_parameters

      send(method) if respond_to?(method)
    end
    myself.status == code.success
  end

  #---

  def operation_deploy
    yield if block_given?
  end

  #---

  def operation_destroy
    yield if block_given?
  end

  #-----------------------------------------------------------------------------
  # Utilities

  def execute_functions
    execute_value = lambda do |value|
      if value.is_a?(String) && match = value.match(/\<\<([^\>]+)\>\>/)
        match.captures.each do |function_id|
          function_components = function_id.split(':')
          function_provider = function_components.shift
          function_args = function_components

          function = CM.function({}, function_provider)
          rendered_output = function.execute(function_args)

          value.gsub!(/\<\<#{function_id}\>\>/, rendered_output)
        end
      end
      value
    end

    execute = lambda do |settings|
      settings.each do |name, value|
        if value.is_a?(Hash)
          execute.call(value)
        elsif value.is_a?(Array)
          final = []
          value.each do |item|
            final << execute_value.call(item)
          end
          settings[name] = final
        else
          settings[name] = execute_value.call(value)
        end
      end
    end

    execute.call(settings[:parameters])
  end

  #---

  def interpolate_parameters
    interpolate_value = lambda do |base_config, name, value|
      interpolations = false
      plan.tokens.each do |token_name, token_value|
        if value.is_a?(String) && value.gsub!(/\{\{#{token_name}\}\}/, token_value.to_s)
          interpolations = true
        end
      end
      base_config[name] = value
      interpolations
    end

    interpolate = lambda do |settings|
      interpolations = false

      if settings.is_a?(Hash)
        settings.each do |name, value|
          if value.is_a?(Hash) || value.is_a?(Array)
            interpolations = true if interpolate.call(value)
          else
            interpolations = true if interpolate_value.call(settings, name, value)
          end
        end
      elsif settings.is_a?(Array)
        settings.each_with_index do |value, index|
          if value.is_a?(Hash) || value.is_a?(Array)
            interpolations = true if interpolate.call(value)
          else
            interpolations = true if interpolate_value.call(settings, index, value)
          end
        end
      end
      interpolations
    end

    tries = 0
    loop do
      tries += 1
      init_tokens
      break if tries >= 10 || !interpolate.call(settings[:parameters])
    end
  end
end
end
end
