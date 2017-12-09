# frozen_string_literal: true

module Icinga2

  # namespace for service handling
  module Services

    # add service
    #
    # @param [Hash] params
    # @option params [String] name
    # @option params [String] host_name
    # @option params [String] display_name
    # @option params [Array] templates
    # @option params [Array] groups
    # @option params [String] notes
    # @option params [String] notes_url
    # @option params [String] action_url
    # @option params [String] check_command
    # @option params [Integer] check_interval
    # @option params [String] check_period
    # @option params [Integer] check_timeout
    # @option params [String] command_endpoint
    # @option params [Boolean] enable_active_checks
    # @option params [Boolean] enable_event_handler
    # @option params [Boolean] enable_flapping
    # @option params [Boolean] enable_notifications
    # @option params [Boolean] enable_passive_checks
    # @option params [Boolean] enable_perfdata
    # @option params [String] event_command
    # @option params [Integer] flapping_threshold_high
    # @option params [Integer] flapping_threshold_low
    # @option params [Integer] flapping_threshold
    # @option params [String] icon_image_alt
    # @option params [String] icon_image
    # @option params [Integer] max_check_attempts
    # @option params [Integer] retry_interval
    # @option params [Boolean] volatile
    # @option params [Hash] vars
    #
    # @example
    #    @icinga.add_service(
    #      name: 'http2',
    #      host_name: 'icinga2',
    #      check_command: 'http',
    #      check_interval: 10,
    #      retry_interval: 30,
    #      vars: {
    #        http_address: '127.0.0.1',
    #        http_url: '/access/index',
    #        http_port: 80
    #      }
    #    )
    #
    # @return [Hash]
    #    * status
    #    * message
    #
    def add_service( params )

      raise ArgumentError.new(format('wrong type. params must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      name    = validate( params, required: true, var: 'name', type: String )
      host_name    = validate( params, required: true, var: 'host_name', type: String )
      display_name   = validate( params, required: false, var: 'display_name', type: String )
      groups   = validate( params, required: false, var: 'groups', type: Array )
      check_command = validate( params, required: false, var: 'check_command', type: String )
      max_check_attempts = validate( params, required: false, var: 'max_check_attempts', type: Integer ) || 3
      check_interval = validate( params, required: false, var: 'check_interval', type: Integer ) || 60
      check_period   = validate( params, required: false, var: 'check_period', type: Integer )
      check_timeout = validate( params, required: false, var: 'check_timeout', type: Integer )
      retry_interval   = validate( params, required: false, var: 'retry_interval', type: Integer ) || 45
      enable_active_checks = validate( params, required: false, var: 'enable_active_checks', type: Boolean )
      enable_event_handler = validate( params, required: false, var: 'enable_event_handler', type: Boolean )
      enable_flapping   = validate( params, required: false, var: 'enable_flapping', type: Boolean )
      enable_notifications = validate( params, required: false, var: 'enable_notifications', type: Boolean ) || false
      enable_passive_checks = validate( params, required: false, var: 'enable_passive_checks', type: Boolean )
      flapping_threshold = validate( params, required: false, var: 'flapping_threshold', type: Integer )
      enable_perfdata   = validate( params, required: false, var: 'enable_perfdata', type: Boolean )
      event_command = validate( params, required: false, var: 'event_command', type: String )
      volatile = validate( params, required: false, var: 'volatile', type: Boolean )
      zone   = validate( params, required: false, var: 'zone', type: String )
      command_endpoint = validate( params, required: false, var: 'command_endpoint', type: String )
      notes    = validate( params, required: false, var: 'notes', type: String )
      notes_url   = validate( params, required: false, var: 'notes_url', type: String )
      action_url = validate( params, required: false, var: 'action_url', type: String )
      icon_image    = validate( params, required: false, var: 'icon_image', type: String )
      icon_image_alt   = validate( params, required: false, var: 'icon_image_alt', type: String )
      templates   = validate( params, required: false, var: 'templates', type: Array ) || ['generic-service']
      vars   = validate( params, required: false, var: 'vars', type: Hash ) || {}

      # check if host exists
      return { 'code' => 404, 'name' => host_name, 'status' => 'Object not Found' } unless( exists_host?( host_name ) )

      payload = {
        templates: templates,
        attrs: {
          display_name: display_name,
          groups: groups,
          check_command: check_command,
          max_check_attempts: max_check_attempts,
          check_period: check_period,
          check_timeout: check_timeout,
          check_interval: check_interval,
          retry_interval: retry_interval,
          enable_notifications: enable_notifications,
          enable_active_checks: enable_active_checks,
          enable_passive_checks: enable_passive_checks,
          enable_event_handler: enable_event_handler,
          enable_flapping: enable_flapping,
          flapping_threshold: flapping_threshold,
          zone: zone,
          enable_perfdata: enable_perfdata,
          event_command: event_command,
          volatile: volatile,
          command_endpoint: command_endpoint,
          notes: notes,
          notes_url: notes_url,
          action_url: action_url,
          icon_image: icon_image,
          icon_image_alt: icon_image_alt,
          vars: vars
        }
      }

      # clear undefined settings
      payload.reject!{ |_k, v| v.nil? }
      payload[:attrs].reject!{ |_k, v| v.nil? }

      put(
        url: format( '%s/objects/services/%s!%s', @icinga_api_url_base, host_name, name ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # delete a service
    #
    # @param [Hash] params
    # @option params [String] name service name
    # @option params [String] host_name host name for the service
    # @option params [Bool] cascade (false) delete service also when other objects depend on it
    #
    # @example
    #   @icinga.delete_service(host_name: 'foo', name: 'http2')
    #   @icinga.delete_service(host_name: 'foo', name: 'http2', cascade: true)
    #
    # @return [Hash] result
    #
    def delete_service( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      name      = validate( params, required: true, var: 'name', type: String )
      host_name = validate( params, required: true, var: 'host_name', type: String )
      cascade   = validate( params, required: false, var: 'cascade', type: Boolean ) || false

      url = format( '%s/objects/services/%s!%s%s', @icinga_api_url_base, host_name, name, cascade.is_a?(TrueClass) ? '?cascade=1' : nil )

      delete(
        url: url,
        headers: @headers,
        options: @options
      )

    end

    # modify an service
    #
    # @param [Hash] params
    # @option params [String] name
    # @option params [Array] templates
    # @option params [Hash] vars
    #
    # @example
    #    @icinga.modify_service(
    #      name: 'http2',
    #      check_interval: 60,
    #      retry_interval: 10,
    #      vars: {
    #        http_url: '/access/login'     ,
    #        http_address: '10.41.80.63'
    #      }
    #    )
    #
    # @return [Hash]
    #    * status
    #    * message
    #
    def modify_service( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing \'params\'') if( params.size.zero? )

      name    = validate( params, required: true, var: 'name', type: String )
      display_name   = validate( params, required: false, var: 'display_name', type: String )
      groups   = validate( params, required: false, var: 'groups', type: Array )
      check_command = validate( params, required: false, var: 'check_command', type: String )
      max_check_attempts = validate( params, required: false, var: 'max_check_attempts', type: Integer ) || 3
      check_interval = validate( params, required: false, var: 'check_interval', type: Integer ) || 60
      check_period   = validate( params, required: false, var: 'check_period', type: Integer )
      check_timeout = validate( params, required: false, var: 'check_timeout', type: Integer )
      retry_interval   = validate( params, required: false, var: 'retry_interval', type: Integer ) || 45
      enable_active_checks = validate( params, required: false, var: 'enable_active_checks', type: Boolean )
      enable_event_handler = validate( params, required: false, var: 'enable_event_handler', type: Boolean )
      enable_flapping   = validate( params, required: false, var: 'enable_flapping', type: Boolean )
      enable_notifications = validate( params, required: false, var: 'enable_notifications', type: Boolean ) || false
      enable_passive_checks = validate( params, required: false, var: 'enable_passive_checks', type: Boolean )
      flapping_threshold = validate( params, required: false, var: 'flapping_threshold', type: Integer )
      enable_perfdata   = validate( params, required: false, var: 'enable_perfdata', type: Boolean )
      event_command = validate( params, required: false, var: 'event_command', type: String )
      volatile = validate( params, required: false, var: 'volatile', type: Boolean )
      zone   = validate( params, required: false, var: 'zone', type: String )
      command_endpoint = validate( params, required: false, var: 'command_endpoint', type: String )
      notes    = validate( params, required: false, var: 'notes', type: String )
      notes_url   = validate( params, required: false, var: 'notes_url', type: String )
      action_url = validate( params, required: false, var: 'action_url', type: String )
      icon_image    = validate( params, required: false, var: 'icon_image', type: String )
      icon_image_alt   = validate( params, required: false, var: 'icon_image_alt', type: String )
      templates   = validate( params, required: false, var: 'templates', type: Array ) || ['generic-service']
      vars   = validate( params, required: false, var: 'vars', type: Hash ) || {}

      # check if service exists
#       return { 'code' => 404, 'name' => name, 'status' => 'Object not Found' } unless( exists_service?( host_name: host_name, service_name: name ) )
#       # check if host exists
#       return { 'code' => 404, 'name' => host_name, 'status' => 'Object not Found' } unless( exists_host?( host_name ) )

      payload = {
        templates: templates,
        filter: format( 'service.name == "%s"', name ),
        attrs: {
          display_name: display_name,
          groups: groups,
          check_command: check_command,
          max_check_attempts: max_check_attempts,
          check_period: check_period,
          check_timeout: check_timeout,
          check_interval: check_interval,
          retry_interval: retry_interval,
          enable_notifications: enable_notifications,
          enable_active_checks: enable_active_checks,
          enable_passive_checks: enable_passive_checks,
          enable_event_handler: enable_event_handler,
          enable_flapping: enable_flapping,
          flapping_threshold: flapping_threshold,
          zone: zone,
          enable_perfdata: enable_perfdata,
          event_command: event_command,
          volatile: volatile,
          command_endpoint: command_endpoint,
          notes: notes,
          notes_url: notes_url,
          action_url: action_url,
          icon_image: icon_image,
          icon_image_alt: icon_image_alt,
          vars: vars
        }
      }

      # clear undefined settings
      payload.reject!{ |_k, v| v.nil? }
      payload[:attrs].reject!{ |_k, v| v.nil? }

      post(
        url: format( '%s/objects/services', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # return all unhandled services
    #
    # @example
    #    @icinga.unhandled_services
    #
    # @return [Hash]
    #
    def unhandled_services

      filter = 'service.state != ServiceOK && service.downtime_depth == 0.0 && service.acknowledgement == 0.0'
      attrs  = %w[__name name state acknowledgement downtime_depth last_check]

      payload = {
        attrs: attrs,
        filter: filter
      }

      # remove all empty attrs
      payload.reject!{ |_k, v| v.nil? }
      payload[:attrs].reject!{ |_k, v| v.nil? }

      api_data(
        url: format( '%s/objects/services', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # return services
    #
    # @param [Hash] params
    # @option params [String] host_name
    # @option params [String] name
    #
    # @example to get all services
    #    @icinga.services
    #
    # @example to get one service for host
    #    @icinga.services( host_name: 'icinga2', name: 'ping4' )
    #
    # @return [Hash]
    #
    def services( params = {} )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )

      host_name = validate( params, required: false, var: 'host_name', type: String )
      name      = validate( params, required: false, var: 'name', type: String )

      url = format( '%s/objects/services/%s', @icinga_api_url_base, host_name )
      url = format( '%s/objects/services/%s!%s', @icinga_api_url_base, host_name, name ) unless( name.nil? )

      api_data(
        url: url,
        headers: @headers,
        options: @options
      )
    end

    # returns true if the service exists
    #
    # @param [Hash] params
    # @option params [String] host_name
    # @option params [String] name
    #
    # @example
    #    @icinga.exists_service?(host_name: 'icinga2', name: 'users')
    #
    # @return [Bool]
    #
    def exists_service?( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      host_name = validate( params, required: true, var: 'host_name', type: String )
      name      = validate( params, required: true, var: 'name', type: String )

      result = services( host_name: host_name, name: name )
      result = JSON.parse( result ) if  result.is_a?( String )
      result = result.first if( result.is_a?(Array) )

      return false if( result.is_a?(Hash) && result.dig('code') == 404 )

      true
    end

    # returns service objects
    #
    # @param [Hash] params
    # @option params [Array] attrs (['name', 'state', 'acknowledgement', 'downtime_depth', 'last_check'])
    # @option params [String] filter ([])
    # @option params [Array] joins (['host.name','host.state','host.acknowledgement','host.downtime_depth','host.last_check'])
    #
    # @example with default attrs and joins
    #    @icinga.service_objects
    #
    # @example
    #    @icinga.service_objects(attrs: ['name', 'state'], joins: ['host.name','host.state'])
    #
    # @return [Array]
    #
    def service_objects( params = {} )

      attrs   = validate( params, required: false, var: 'attrs', type: Array ) || %w[name state acknowledgement downtime_depth  last_check]
      filter  = validate( params, required: false, var: 'filter', type: String )
      joins   = validate( params, required: false, var: 'joins', type: Array ) || ['host.name', 'host.state', 'host.acknowledgement', 'host.downtime_depth', 'host.last_check']

      payload = {
        attrs: attrs,
        filter: filter,
        joins: joins
      }

      payload.reject!{ |_k, v| v.nil? }

      data = api_data(
        url: format( '%s/objects/services', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload
      )

      @last_service_objects_called = Time.now.to_i

      if( !data.nil? && data.is_a?(Array) )
        all_services = data.clone
        unless( all_services.nil? )
          @services_all              = all_services.size
          @services_problems         = count_problems(all_services)
          @services_handled_warning  = count_problems(all_services, Icinga2::SERVICE_STATE_WARNING)
          @services_handled_critical = count_problems(all_services, Icinga2::SERVICE_STATE_CRITICAL)
          @services_handled_unknown  = count_problems(all_services, Icinga2::SERVICE_STATE_UNKNOWN)
        end
      end

      data
    end

    # returns adjusted service state
    #
    # @example
    #    warning, critical, unknown = @icinga.services_adjusted.values
    #
    #    s = @icinga.services_adjusted
    #    unknown = s.dig(:unknown)
    #
    # @return [Hash]
    #    * warning
    #    * critical
    #    * unknown
    #
    def services_adjusted

      puts 'function services_adjusted is obsolete'
      puts 'Please use service_problems()'

      cib_data if((Time.now.to_i - @last_cib_data_called).to_i > @last_call_timeout)
      service_objects if((Time.now.to_i - @last_service_objects_called).to_i > @last_call_timeout)

      service_warning          = @services_warning.nil?          ? 0 : @services_warning
      service_critical         = @services_critical.nil?         ? 0 : @services_critical
      service_unknown          = @services_unknown.nil?          ? 0 : @services_unknown
      service_handled_warning  = @services_handled_warning.nil?  ? 0 : @services_handled_warning
      service_handled_critical = @services_handled_critical.nil? ? 0 : @services_handled_critical
      service_handled_unknown  = @services_handled_unknown.nil?  ? 0 : @services_handled_unknown

      # calculate service problems adjusted by handled problems
      service_adjusted_warning  = service_warning  - service_handled_warning
      service_adjusted_critical = service_critical - service_handled_critical
      service_adjusted_unknown  = service_unknown  - service_handled_unknown

      {
        warning: service_adjusted_warning.to_i,
        critical: service_adjusted_critical.to_i,
        unknown: service_adjusted_unknown.to_i
      }
    end

    # return count of services with problems
    #
    # @example
    #    @icinga.count_services_with_problems
    #
    # @return [Integer]
    #
    def count_services_with_problems

      service_data = service_objects
      service_data = JSON.parse(service_data) if service_data.is_a?(String)

      return 0 if( service_data.nil? )

      f = service_data.select { |t| t.dig('attrs','state') != 0 && t.dig('attrs','downtime_depth').zero? && t.dig('attrs','acknowledgement').zero? }

      f.size
    end

    # return a list of services with problems
    #
    # @param [Integer] max_items numbers of list entries
    #
    # @example
    #    problems, problems_and_severity = @icinga.list_services_with_problems.values
    #
    #    l = @icinga.list_services_with_problems
    #    problems_and_severity = l.dig(:services_with_problems_and_severity)
    #
    # @return [Hash]
    #    * Array (services_with_problems)
    #    * Hash  (services_with_problems_and_severity)
    #
    def list_services_with_problems( max_items = 5 )

      raise ArgumentError.new(format('wrong type. \'max_items\' must be an Integer, given \'%s\'', max_items.class.to_s)) unless( max_items.is_a?(Integer) )

      services_with_problems = {}
      services_with_problems_and_severity = {}

      # only fetch the minimal attribute set required for severity calculation
      services_data = service_objects
      services_data = JSON.parse( services_data ) if services_data.is_a?(String)

      unless( services_data.nil? )
        services_data.each do |s|
          name  = s.dig('name')
          state = s.dig('attrs','state')

          next if  state.zero?

          services_with_problems[name] = service_severity(s)
        end

        if( services_with_problems.count != 0 )
          services_with_problems.sort.reverse!
          services_with_problems = services_with_problems.keys[1..max_items].each { |k| services_with_problems_and_severity[k] = services_with_problems[k] }
        end
      end

      {
        services_with_problems: services_with_problems,
        services_with_problems_and_severity: services_with_problems_and_severity
      }
    end

    # returns a counter of all services
    #
    # @example
    #    @icinga.services_all
    #
    # @return [Integer]
    #
    def services_all

      cib_data if((Time.now.to_i - @last_cib_data_called).to_i > @last_call_timeout)
      service_objects if((Time.now.to_i - @last_service_objects_called).to_i > @last_call_timeout)

      @services_all
    end

    # returns data with service problems
    #
    # @example
    #    all, warning, critical, unknown, pending, in_downtime, acknowledged, adjusted_warning, adjusted_critical, adjusted_unknown = @icinga.service_problems.values
    #
    #    p = @icinga.service_problems
    #    warning = p.dig(:warning)
    #
    # @return [Hash]
    #    * ok
    #    * warning
    #    * critical
    #    * unknown
    #    * pending
    #    * in_downtime
    #    * acknowledged
    #
    def service_problems

      cib_data if((Time.now.to_i - @last_cib_data_called).to_i > @last_call_timeout)
      service_objects if((Time.now.to_i - @last_service_objects_called).to_i > @last_call_timeout)

      services_ok               = @services_ok.nil?               ? 0 : @services_ok
      services_warning          = @services_warning.nil?          ? 0 : @services_warning
      services_critical         = @services_critical.nil?         ? 0 : @services_critical
      services_unknown          = @services_unknown.nil?          ? 0 : @services_unknown
      services_pending          = @services_pending.nil?          ? 0 : @services_pending
      services_in_downtime      = @services_in_downtime.nil?      ? 0 : @services_in_downtime
      services_acknowledged     = @services_acknowledged.nil?     ? 0 : @services_acknowledged
      services_handled_all      = @services_handled.nil?          ? 0 : @services_handled
      services_handled_warning  = @services_handled_warning.nil?  ? 0 : @services_handled_warning
      services_handled_critical = @services_handled_critical.nil? ? 0 : @services_handled_critical
      services_handled_unknown  = @services_handled_unknown.nil?  ? 0 : @services_handled_unknown

      # calculate service problems adjusted by handled problems
      services_adjusted_warning  = services_warning  - services_handled_warning
      services_adjusted_critical = services_critical - services_handled_critical
      services_adjusted_unknown  = services_unknown  - services_handled_unknown

      {
        ok: services_ok.to_i,
        warning: services_critical.to_i,
        critical: services_warning.to_i,
        unknown: services_unknown.to_i,
        pending: services_pending.to_i,
        in_downtime: services_in_downtime.to_i,
        acknowledged: services_acknowledged.to_i,
        adjusted_warning: services_adjusted_warning.to_i,
        adjusted_critical: services_adjusted_critical.to_i,
        adjusted_unknown: services_adjusted_unknown.to_i,
        handled_all: services_handled_all.to_i,
        handled_warning: services_handled_warning.to_i,
        handled_critical: services_handled_critical.to_i,
        handled_unknown: services_handled_unknown.to_i
      }
    end

    # returns data with service problems they be handled (acknowledged or in downtime)
    #
    # @example
    #    @icinga.service_objects
    #    all, warning, critical, unknown = @icinga.service_problems_handled.values
    #
    #    p = @icinga.service_problems_handled
    #    warning = p.dig(:warning)
    #
    # @return [Hash]
    #    * all
    #    * critical
    #    * warning
    #    * unknown
    #
    def service_problems_handled

      puts 'function service_problems_handled is obsolete'
      puts 'Please use service_problems()'

      cib_data if((Time.now.to_i - @last_cib_data_called).to_i > @last_call_timeout)

      problems_all      = @services_handled.nil?          ? 0 : @services_handled
      problems_critical = @services_handled_critical.nil? ? 0 : @services_handled_critical
      problems_warning  = @services_handled_warning.nil?  ? 0 : @services_handled_warning
      problems_unknown  = @services_handled_unknown.nil?  ? 0 : @services_handled_unknown

      {
        all: problems_all.to_i,
        warning: problems_warning.to_i,
        critical: problems_critical.to_i,
        unknown: problems_unknown.to_i
      }
    end

    protected
    # calculate a service severity
    #
    # stolen from Icinga Web 2
    # ./modules/monitoring/library/Monitoring/Backend/Ido/Query/ServicestatusQuery.php
    #
    # @param [Hash] params
    # @option params [hash] attrs ()
    #   * state [Float]
    #   * acknowledgement [Float] (default: 0)
    #   * downtime_depth [Float] (default: 0)
    #
    # @api protected
    #
    # @example
    #   service_severity( {'attrs' => { 'state' => 0.0, 'acknowledgement' => 0.0, 'downtime_depth' => 0.0 } } )
    #
    # @return [Integer]
    #
    def service_severity( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      attrs = params.dig('attrs')

      state           = validate( attrs, required: true, var: 'state', type: Float )
      acknowledgement = validate( attrs, required: false, var: 'acknowledgement', type: Float ) || 0
      downtime_depth  = validate( attrs, required: false, var: 'downtime_depth', type: Float ) || 0

      severity = 0

      severity +=
        if acknowledgement != 0
          2
        elsif downtime_depth > 0
          1
        else
          4
        end

      severity += 16 if object_has_been_checked?(params)

      unless state.zero?
        severity +=
          if state == 1
            32
          elsif state == 2
            64
          else
            256
          end

        # requires joins
        host_attrs = params.dig('joins','host')

        return 0 if( host_attrs.nil? )

        host_state           = host_attrs.dig('state')
        host_acknowledgement = host_attrs.dig('acknowledgement')
        host_downtime_depth  = host_attrs.dig('downtime_depth')

        severity +=
          if host_state > 0
            1024
          elsif host_acknowledgement
            512
          elsif host_downtime_depth > 0
            256
          else
            2048
          end

      end

      severity
    end

  end
end
