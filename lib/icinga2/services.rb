
# frozen_string_literal: true

module Icinga2

  #
  #
  #
  module Services

    #
    #
    #
    def add_services( host, services = {} )

      services.each do |s,v|

        payload = {
          'templates' => [ 'generic-service' ],
          'attrs'     => update_host( v, host )
        }

        logger.debug( s )
        logger.debug( v.to_json )

        logger.debug( JSON.pretty_generate( payload ) )

        result = Network.put(           host: host,
          url: format( '%s/v1/objects/services/%s!%s', @icinga_api_url_base, host, s ),
          headers: @headers,
          options: @options,
          payload: payload)

        logger.debug( result )

      end

    end

    #
    #
    #
    def unhandled_services( params = {} )

      # taken from https://blog.netways.de/2016/11/18/icinga-2-api-cheat-sheet/
      # 5) Anzeige aller Services die unhandled sind und weder in Downtime, noch acknowledged sind
      # /usr/bin/curl -k -s -u 'root:icinga' -H 'X-HTTP-Method-Override: GET' -X POST 'https://127.0.0.1:5665/v1/objects/services' -d '{ "attrs": [ "__name", "state", "downtime_depth", "acknowledgement" ], "filter": "service.state != ServiceOK && service.downtime_depth == 0.0 && service.acknowledgement == 0.0" }''' | jq

    end

    #
    #
    #
    def services( params = {} )

      name    = params.dig(:host)
      service = params.dig(:service)

      url = if( service.nil? )
        format( '%s/v1/objects/services/%s', @icinga_api_url_base, name )
      else
        format( '%s/v1/objects/services/%s!%s', @icinga_api_url_base, name, service )
            end

      result = Network.get(         host: name,
        url: url,
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )

    end

    #
    #
    #
    def exists_service?( params = {} )

      host    = params.dig(:host)
      service = params.dig(:service)

      if( host.nil? )

        return {
          status: 404,
          message: 'missing host name'
        }
      end

      result = services( host: host, service: service )

      result = JSON.parse( result ) if  result.is_a?( String )

      status = result.dig('status')

      return true if  !status.nil? && status == 200

      false

    end

    #
    #
    #
    def service_objects( params = {} )

      attrs   = params.dig(:attrs)
      filter  = params.dig(:filter)
      joins   = params.dig(:joins)
      payload = {}

      if( attrs.nil? )
        attrs = %w[name state acknowledgement downtime_depth last_check]
      end

      if( joins.nil? )
        joins = ['host.name','host.state','host.acknowledgement','host.downtime_depth','host.last_check']
      end

      payload['attrs'] = attrs unless  attrs.nil?

      payload['filter'] = filter unless  filter.nil?

      payload['joins'] = joins unless  joins.nil?

      result = Network.get(         host: nil,
        url: format( '%s/v1/objects/services', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload )

      JSON.pretty_generate( result )

    end

    #
    #
    #
    def service_problems

      data     = service_objects
      problems = 0

      data = JSON.parse(data) if  data.is_a?(String)

      nodes = data.dig('nodes')

      nodes.each do |n|

        attrs           = n.last.dig('attrs')

        state           = attrs.dig('state')
        downtime_depth   = attrs.dig('downtime_depth')
        acknowledgement = attrs.dig('acknowledgement')

#         puts state

        if( state != 0 && downtime_depth.zero? && acknowledgement.zero? )
          problems += 1 #= problems +1
        end

      end

      problems

    end

    #
    #
    #
    def problem_services( max_items = 5 )

      @service_problems = {}
      @service_problems_severity = {}

      # only fetch the minimal attribute set required for severity calculation
      services_data = service_objects

      if( services_data.is_a?(String) )

        services_data = JSON.parse( services_data )
      end

      services_data = services_data.dig('nodes')

      services_data.each do |_service,v|

        name  = v.dig('name')
        state = v.dig('attrs','state')
#         logger.debug( "Severity for #{name}" )
        next if  state.zero?

        @service_problems[name] = service_severity(v)
      end

      @service_problems.sort.reverse!

      @service_problems.keys[1..max_items].each { |k,_v| @service_problems_severity[k] = @service_problems[k] }

      @service_problems_severity
    end

    #
    #
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

    # private
    # stolen from Icinga Web 2
    # ./modules/monitoring/library/Monitoring/Backend/Ido/Query/ServicestatusQuery.php
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

      severity += 16 if object_has_been_checked?(host)

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

  end
end
