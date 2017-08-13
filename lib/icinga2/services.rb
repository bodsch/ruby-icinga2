
# frozen_string_literal: true

module Icinga2

  # namespace for service handling
  module Services

    # add services
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :services
    #
    # @todo
    #  this function is not operable
    #  need help, time or beer
    #
    # @return [Hash]
    #
    def add_services( params = {} )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )

      # TODO
      puts 'add_services() ToDo'

      host_name = params.dig(:host)
      services  = params.dig(:services)

      services.each do |s,v|

        payload = {
          'templates' => [ 'generic-service' ],
          'attrs'     => update_host( v, host_name )
        }

        logger.debug( s )
        logger.debug( v.to_json )

        logger.debug( JSON.pretty_generate( payload ) )

        Network.put(
          url: format( '%s/objects/services/%s!%s', @icinga_api_url_base, host_name, s ),
          headers: @headers,
          options: @options,
          payload: payload
        )
      end

    end

    # return all unhandled services
    #
    # @param [Hash] params
    #
    # @todo
    #  this function is not operable
    #  need help, time or beer
    #
    # @return [Nil]
    #
    def unhandled_services( params = {} )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )

      # TODO
      puts 'unhandled_services() ToDo'

      # taken from https://blog.netways.de/2016/11/18/icinga-2-api-cheat-sheet/
      # 5) Anzeige aller Services die unhandled sind und weder in Downtime, noch acknowledged sind
      # /usr/bin/curl -k -s -u 'root:icinga' -H 'X-HTTP-Method-Override: GET' -X POST
      # 'https://127.0.0.1:5665/objects/services' #
      # -d '{ "attrs": [ "__name", "state", "downtime_depth", "acknowledgement" ], "filter": "service.state != ServiceOK && service.downtime_depth == 0.0 && service.acknowledgement == 0.0" }''' | jq

    end

    # return services
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :service
    #
    # @example to get all services
    #    @icinga.services
    #
    # @example to get one service for host
    #    @icinga.services( host: 'icinga2', service: 'ping4' )
    #
    # @return [Hash]
    #
    def services( params = {} )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )

      host_name = params.dig(:host)
      service   = params.dig(:service)

      url =
      if( service.nil? )
        format( '%s/objects/services/%s', @icinga_api_url_base, host_name )
      else
        format( '%s/objects/services/%s!%s', @icinga_api_url_base, host_name, service )
      end

      data = Network.api_data(
        url: url,
        headers: @headers,
        options: @options
      )

      return data.dig('results') if( data.dig(:status).nil? )

      nil
    end

    # returns true if the service exists
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :service
    #
    # @example
    #    @icinga.exists_service?(host: 'icinga2', service: 'users' )
    #
    # @return [Bool]
    #
    def exists_service?( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      host    = params.dig(:host)
      service = params.dig(:service)

      raise ArgumentError.new('Missing host') if( host.nil? )
      raise ArgumentError.new('Missing service') if( service.nil? )

      result = services( host: host, service: service )
      result = JSON.parse( result ) if  result.is_a?( String )

      return true if  !result.nil? && result.is_a?(Array)

      false
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
    # @return [Hash]
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

      data = Network.api_data(
        url: format( '%s/objects/services', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload
      )

      status  = data.dig(:status)

      if( status.nil? )

        results = data.dig('results')

        unless( results.nil? )

          all_services = results.clone

          unless( all_services.nil? )

            @services_all              = all_services.size
            @services_problems         = count_problems(results)
            @services_handled_warning  = count_problems(results, Icinga2::SERVICE_STATE_WARNING)
            @services_handled_critical = count_problems(results, Icinga2::SERVICE_STATE_CRITICAL)
            @services_handled_unknown  = count_problems(results, Icinga2::SERVICE_STATE_UNKNOWN)
          end
        end
      end

      results
    end

    # returns adjusted service state
    #
    # @example
    #    @icinga.cib_data
    #    @icinga.service_objects
    #    warning, critical, unknown = @icinga.services_adjusted
    #
    # @return [Array] (warning_adjusted, critical_adjusted, unknown_adjusted)
    #
    def services_adjusted

      warning          = @services_warning.nil?      ? 0 : @services_warning
      critical         = @services_critical.nil?     ? 0 : @services_critical
      unknown          = @services_unknown.nil?      ? 0 : @services_unknown
      handled_warning  = @services_handled_warning.nil?  ? 0 : @services_handled_warning
      handled_critical = @services_handled_critical.nil? ? 0 : @services_handled_critical
      handled_unknown  = @services_handled_unknown.nil?  ? 0 : @services_handled_unknown

      # calculate service problems adjusted by handled problems
      warning_adjusted  = warning  - handled_warning
      critical_adjusted = critical - handled_critical
      unknown_adjusted  = unknown  - handled_unknown

      [warning_adjusted, critical_adjusted, unknown_adjusted]
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

      f = service_data.select { |t| t.dig('attrs','state') != 0 && t.dig('attrs','downtime_depth').zero? && t.dig('attrs','acknowledgement').zero? }

      f.size
    end

    # return a list of services with problems
    #
    # @param [Integer] max_items numbers of list entries
    #
    # @example
    #    @icinga.list_services_with_problems
    #
    # @return [Hash]
    #
    def list_services_with_problems( max_items = 5 )

      count_services_with_problems = {}
      count_services_with_problems_severity = {}

      # only fetch the minimal attribute set required for severity calculation
      services_data = service_objects
      services_data = JSON.parse( services_data ) if services_data.is_a?(String)

      unless( services_data.nil? )

        services_data.each do |s,_v|

          name  = s.dig('name')
          state = s.dig('attrs','state')
          next if  state.zero?

          count_services_with_problems[name] = service_severity(s)
        end

        if( count_services_with_problems.count != 0 )
          count_services_with_problems.sort.reverse!
          count_services_with_problems = count_services_with_problems.keys[1..max_items].each { |k,_v| count_services_with_problems_severity[k] = count_services_with_problems[k] }
        end
      end

      @count_services_with_problems          = count_services_with_problems
      @count_services_with_problems_severity = count_services_with_problems_severity

      [count_services_with_problems, count_services_with_problems_severity]
    end

    # update host
    #
    # @param [Hash] hash
    # @param [String] host
    #
    # @todo
    #  this function are not operable
    #  need help, time or beer
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

    # calculate a service severity
    #
    # stolen from Icinga Web 2
    # ./modules/monitoring/library/Monitoring/Backend/Ido/Query/ServicestatusQuery.php
    #
    # @param [Hash] service
    #
    # @private
    #
    # @return [Hash]
    #
    def service_severity( service )

      attrs           = service.dig('attrs')
      state           = attrs.dig('state')
      acknowledgement = attrs.dig('acknowledgement') || 0
      downtime_depth  = attrs.dig('downtime_depth')  || 0

      severity = 0

      severity +=
        if acknowledgement != 0
          2
        elsif downtime_depth > 0
          1
        else
          4
        end

      severity += 16 if object_has_been_checked?(service)

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
        host_attrs = service.dig('joins','host')
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


    # returns a counter of all services
    #
    # @example
    #    @icinga.service_objects
    #    @icinga.services_all
    #
    # @return [Integer]
    #
    def services_all
      @services_all
    end

    # returns a counter of all services with problems (critical, warning, unknown state)
    #
    # @example
    #    @icinga.service_objects
    #    @icinga.services_problems
    #
    # @return [Integer]
    #
    def services_problems
      @services_problems
    end

    # returns a counter of services with critical state
    #
    # @example
    #    @icinga.service_objects
    #    @icinga.services_critical
    #
    # @return [Integer]
    #
    def services_critical
      @services_critical
    end

    # returns a counter of services with warning state
    #
    # @example
    #    @icinga.service_objects
    #    @icinga.services_warning
    #
    # @return [Integer]
    #
    def services_warning
      @services_warning
    end

    # returns a counter of services with unknown state
    #
    # @example
    #    @icinga.service_objects
    #    @icinga.services_unknown
    #
    # @return [Integer]
    #
    def services_unknown
      @services_unknown
    end

    # returns a counter of handled (acknowledged or downtimed) services with critical state
    #
    # @example
    #    @icinga.service_objects
    #    @icinga.services_handled_critical
    #
    # @return [Integer]
    #
    def services_handled_critical
      @services_handled_critical
    end

    # returns a counter of handled (acknowledged or downtimed) services with warning state
    #
    # @example
    #    @icinga.service_objects
    #    @icinga.services_handled_warning
    #
    # @return [Integer]
    #
    def services_handled_warning
      @services_handled_warning
    end

    # returns a counter of handled (acknowledged or downtimed) services with unknown state
    #
    # @example
    #    @icinga.service_objects
    #    @icinga.services_handled_unknown
    #
    # @return [Integer]
    #
    def services_handled_unknown
      @services_handled_unknown
    end


    #
    # @deprecated use {services_handled_critical} instead.
    #
    def services_handled_critical_problems
      @services_handled_critical
    end

    #
    # @deprecated use {services_handled_warning} instead.
    #
    def services_handled_warning_problems
      @services_handled_warning
    end

    #
    # @deprecated use {services_handled_unknown} instead.
    #
    def services_handled_unknown_problems
      @services_handled_unknown
    end

  end
end
