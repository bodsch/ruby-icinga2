# frozen_string_literal: true

module Icinga2

  # namespace for service handling
  module Services extend Validator

    # add service
    #
    # @param [Hash] params
    # @option params [String] :name
    # @option params [String] :host_name
    # @option params [String] :display_name
    # @option params [Array] :templates
    # @option params [Array] :groups
    # @option params [String] :notes
    # @option params [String] :notes_url
    # @option params [String] :action_url
    # @option params [String] :check_command
    # @option params [Integer] :check_interval
    # @option params [String] :check_period
    # @option params [Integer] :check_timeout
    # @option params [String] :command_endpoint
    # @option params [Boolean] :enable_active_checks
    # @option params [Boolean] :enable_event_handler
    # @option params [Boolean] :enable_flapping
    # @option params [Boolean] :enable_notifications
    # @option params [Boolean] :enable_passive_checks
    # @option params [Boolean] :enable_perfdata
    # @option params [String] :event_command
    # @option params [Integer] :flapping_threshold_high
    # @option params [Integer] :flapping_threshold_low
    # @option params [Integer] :flapping_threshold
    # @option params [String] :icon_image_alt
    # @option params [String] :icon_image
    # @option params [Integer] :max_check_attempts
    # @option params [Integer] :retry_interval
    # @option params [Boolean] :volatile
    # @option params [Hash] :vars
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

      name = params.dig(:name)
      host_name = params.dig(:host_name)
      display_name = params.dig(:display_name)
      groups = params.dig(:groups)
      check_command = params.dig(:check_command)
      max_check_attempts = params.dig(:max_check_attempts)
      check_period = params.dig(:check_period)
      check_timeout = params.dig(:check_timeout)
      check_interval = params.dig(:check_interval)
      retry_interval = params.dig(:retry_interval)
      enable_notifications = params.dig(:enable_notifications)
      enable_active_checks = params.dig(:enable_active_checks)
      enable_passive_checks = params.dig(:enable_passive_checks)
      enable_event_handler = params.dig(:enable_event_handler)
      enable_flapping = params.dig(:enable_flapping)
      flapping_threshold = params.dig(:flapping_threshold)
      enable_perfdata = params.dig(:enable_perfdata)
      event_command = params.dig(:event_command)
      volatile = params.dig(:volatile)
      zone = params.dig(:zone)
      command_endpoint = params.dig(:command_endpoint)
      notes = params.dig(:notes)
      notes_url = params.dig(:notes_url)
      action_url = params.dig(:action_url)
      icon_image = params.dig(:icon_image)
      icon_image_alt = params.dig(:icon_image_alt)
      templates = params.dig(:templates) || ['generic-service']
      vars = params.dig(:vars) || {}

      raise ArgumentError.new('missing name') if( name.nil? )

      %w[display_name
         host_name
         check_command
         check_period
         event_command
         zone
         name
         command_endpoint
         notes
         notes_url
         action_url
         icon_image
         icon_image_alt
         ].each do |attr|
#           v = eval(attr)
        v  = params.dig(attr.to_sym)
        raise ArgumentError.new(format('wrong type. \'%s\' must be an String, given \'%s\'', attr, v.class.to_s)) unless( v.is_a?(String) || v.nil? )
      end

      %w[max_check_attempts
         flapping_threshold
         check_timeout
         check_interval
         retry_interval].each do |attr|
#           v = eval(attr)
        v  = params.dig(attr.to_sym)
        raise ArgumentError.new(format('wrong type. \'%s\' must be an Integer, given \'%s\'', attr, v.class.to_s)) unless( v.is_a?(Integer) || v.nil? )
      end

      %w[enable_notifications
         enable_active_checks
         enable_passive_checks
         enable_event_handler
         enable_flapping
         enable_perfdata
         volatile].each do |attr|
#           v = eval(attr)
          v  = params.dig(attr.to_sym)
          raise ArgumentError.new(format('wrong type. \'%s\' must be True or False, given \'%s\'', attr, v.class.to_s)) unless( v.is_a?(TrueClass) || v.is_a?(FalseClass) || v.nil? )
      end

      %w[groups templates].each do |attr|
#           v = eval(attr)
          v  = params.dig(attr.to_sym)
          raise ArgumentError.new(format('wrong type. \'%s\' must be an Array, given \'%s\'', attr, v.class.to_s)) unless( v.is_a?(Array) || v.nil? )
      end

      raise ArgumentError.new(format('wrong type. \'vars\' must be an Hash, given \'%s\'', v.class.to_s)) unless( vars.is_a?(Hash) )


#       validate_options!( params,
#         required: [:name, :host_name, :check_command],
#         optional: [:display_name, :groups, ]
#       )


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
    # @option params [String] :host_name host name for the service
    # @option params [String] :name
    # @option params [Bool] :cascade (false) delete service also when other objects depend on it
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

      host_name    = params.dig(:host_name)
      name = params.dig(:name)
      cascade      = params.dig(:cascade)

      raise ArgumentError.new('Missing host') if( host_name.nil? )
      raise ArgumentError.new('Missing service name') if( name.nil? )

      if( ! cascade.nil? && ( ! cascade.is_a?(TrueClass) && ! cascade.is_a?(FalseClass) ) )
        raise ArgumentError.new('cascade can only be true or false')
      end

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
    # @option params [String] :name
    # @option params [Array] :templates
    # @option params [Hash] :vars
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

      name = params.dig(:name)
      display_name = params.dig(:display_name)
      groups = params.dig(:groups)
      check_command = params.dig(:check_command)
      max_check_attempts = params.dig(:max_check_attempts)
      check_period = params.dig(:check_period)
      check_timeout = params.dig(:check_timeout)
      check_interval = params.dig(:check_interval)
      retry_interval = params.dig(:retry_interval)
      enable_notifications = params.dig(:enable_notifications)
      enable_active_checks = params.dig(:enable_active_checks)
      enable_passive_checks = params.dig(:enable_passive_checks)
      enable_event_handler = params.dig(:enable_event_handler)
      enable_flapping = params.dig(:enable_flapping)
      flapping_threshold = params.dig(:flapping_threshold)
      enable_perfdata = params.dig(:enable_perfdata)
      event_command = params.dig(:event_command)
      volatile = params.dig(:volatile)
      zone = params.dig(:zone)
      command_endpoint = params.dig(:command_endpoint)
      notes = params.dig(:notes)
      notes_url = params.dig(:notes_url)
      action_url = params.dig(:action_url)
      icon_image = params.dig(:icon_image)
      icon_image_alt = params.dig(:icon_image_alt)
      templates = params.dig(:templates) || ['generic-service']
      vars = params.dig(:vars) || {}

      raise ArgumentError.new('missing name') if( name.nil? )

      %w[display_name
         host_name
         check_command
         check_period
         event_command
         zone
         name
         command_endpoint
         notes
         notes_url
         action_url
         icon_image
         icon_image_alt
         ].each do |attr|
#           v = eval(attr)
          v  = params.dig(attr.to_sym)
        raise ArgumentError.new(format('wrong type. \'%s\' must be an String, given \'%s\'', attr, v.class.to_s)) unless( v.is_a?(String) || v.nil? )
      end

      %w[max_check_attempts
         flapping_threshold
         check_timeout
         check_interval
         retry_interval].each do |attr|
#           v = eval(attr)
          v  = params.dig(attr.to_sym)
        raise ArgumentError.new(format('wrong type. \'%s\' must be an Integer, given \'%s\'', attr, v.class.to_s)) unless( v.is_a?(Integer) || v.nil? )
      end

      %w[enable_notifications
         enable_active_checks
         enable_passive_checks
         enable_event_handler
         enable_flapping
         enable_perfdata
         volatile].each do |attr|
#           v = eval(attr)
          v  = params.dig(attr.to_sym)
          raise ArgumentError.new(format('wrong type. \'%s\' must be True or False, given \'%s\'', attr, v.class.to_s)) unless( v.is_a?(TrueClass) || v.is_a?(FalseClass) || v.nil? )
      end

      %w[groups templates].each do |attr|
#           v = eval(attr)
          v  = params.dig(attr.to_sym)
          raise ArgumentError.new(format('wrong type. \'%s\' must be an Array, given \'%s\'', attr, v.class.to_s)) unless( v.is_a?(Array) || v.nil? )
      end

      raise ArgumentError.new(format('wrong type. \'vars\' must be an Hash, given \'%s\'', v.class.to_s)) unless( vars.is_a?(Hash) )

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

      payload = {}

      filter = 'service.state != ServiceOK && service.downtime_depth == 0.0 && service.acknowledgement == 0.0'
      attrs  = %w[__name name state acknowledgement downtime_depth last_check]

      payload['attrs']  = attrs unless  attrs.nil?
      payload['filter'] = filter unless filter.nil?

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
    # @option params [String] :host_name
    # @option params [String] :name
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

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )

      host_name = params.dig(:host_name)
      name   = params.dig(:name)

      url =
      if( name.nil? )
        format( '%s/objects/services/%s', @icinga_api_url_base, host_name )
      else
        format( '%s/objects/services/%s!%s', @icinga_api_url_base, host_name, name )
      end

      api_data(
        url: url,
        headers: @headers,
        options: @options
      )
    end

    # returns true if the service exists
    #
    # @param [Hash] params
    # @option params [String] :host_name
    # @option params [String] :name
    #
    # @example
    #    @icinga.exists_service?(host_name: 'icinga2', name: 'users')
    #
    # @return [Bool]
    #
    def exists_service?( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      host    = params.dig(:host_name)
      service = params.dig(:name)

      raise ArgumentError.new('Missing host') if( host.nil? )
      raise ArgumentError.new('Missing service') if( service.nil? )

      result = services( host_name: host, name: service )
      result = JSON.parse( result ) if  result.is_a?( String )
      result = result.first if( result.is_a?(Array) )

      return false if( result.is_a?(Hash) && result.dig('code') == 404 )

      true
    end

    # returns service objects
    #
    # @param [Hash] params
    # @option params [Array] :attrs (['name', 'state', 'acknowledgement', 'downtime_depth', 'last_check'])
    # @option params [Array] :filter ([])
    # @option params [Array] :joins (['host.name','host.state','host.acknowledgement','host.downtime_depth','host.last_check'])
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

      attrs   = params.dig(:attrs)
      filter  = params.dig(:filter)
      joins   = params.dig(:joins)
      payload = {}

      if( attrs.nil? )
        attrs = %w[name state acknowledgement downtime_depth  last_check]
      end

      if( joins.nil? )
        joins = ['host.name', 'host.state', 'host.acknowledgement', 'host.downtime_depth', 'host.last_check']
      end

      payload['attrs']  = attrs unless  attrs.nil?
      payload['filter'] = filter unless filter.nil?
      payload['joins']  = joins unless  joins.nil?

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

#      [problems_all,problems_critical,problems_warning,problems_unknown]
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

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      state           = params.dig('attrs','state')
      acknowledgement = params.dig('attrs','acknowledgement') || 0
      downtime_depth  = params.dig('attrs','downtime_depth')  || 0

      raise ArgumentError.new('only Float for state are allowed') unless( state.is_a?(Float) )
      raise ArgumentError.new('only Float for acknowledgement are allowed') unless( acknowledgement.is_a?(Float) )
      raise ArgumentError.new('only Float for downtime_depth are allowed') unless( downtime_depth.is_a?(Float) )

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

    private
    # update host
    #
    # @param [Hash] hash
    # @param [String] host
    #
    # @api protected
    #
    # @return [Hash]
    #
    def update_host( hash, host )

      hash.each do |k, v|

        if( k == 'host' && v.is_a?( String ) )
          v.replace( host )

        elsif( v.is_a?( Hash ) )

          update_host( v, host )

        elsif( v.is_a?(Array) )

          v.flatten.each { |x| update_host( x, host ) if x.is_a?( Hash ) }
        end
      end

      hash
    end

  end
end
