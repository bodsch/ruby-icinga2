
# frozen_string_literal: true
module Icinga2

  module Hosts

    def add_host( params = {} )

      name             = params.dig(:name)
      fqdn             = params.dig(:fqdn)
      display_name      = params.dig(:display_name) || name
      notifications    = params.dig(:enable_notifications) || false
      max_check_attempts = params.dig(:max_check_attempts) || 3
      check_interval    = params.dig(:check_interval) || 60
      retry_interval    = params.dig(:retry_interval) || 45
      notes            = params.dig(:notes)
      notes_url         = params.dig(:notes_url)
      action_url        = params.dig(:action_url)
      vars             = params.dig(:vars) || {}

      if( name.nil? )

        return {
          status: 404,
          message: 'missing host name'
        }
      end

      if( fqdn.nil? )
        # build FQDN
        fqdn = Socket.gethostbyname( name ).first
      end

      payload = {
        'templates' => [ 'generic-host' ],
        'attrs'     => {
          'address'              => fqdn,
          'display_name'         => display_name,
          'max_check_attempts'   => max_check_attempts.to_i,
          'check_interval'       => check_interval.to_i,
          'retry_interval'       => retry_interval.to_i,
          'enable_notifications' => notifications,
          'action_url'           => action_url,
          'notes'                => notes,
          'notes_url'            => notes_url
        }
      }

      payload['attrs']['vars'] = vars unless  vars.empty?

      if( @icinga_cluster == true && !@icinga_satellite.nil? )
        payload['attrs']['zone'] = @icinga_satellite
      end

      logger.debug( JSON.pretty_generate( payload ) )

      result = Network.put(         host: name,
        url: format( '%s/v1/objects/hosts/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options,
        payload: payload )

      JSON.pretty_generate( result )

    end


    def delete_host( params = {} )

      name = params.dig(:name)

      if( name.nil? )

        return {
          status: 404,
          message: 'missing host name'
        }
      end

      result = Network.delete(         host: name,
        url: format( '%s/v1/objects/hosts/%s?cascade=1', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )

    end


    def hosts( params = {} )

      name   = params.dig(:name)
      attrs  = params.dig(:attrs)
      filter = params.dig(:filter)
      joins  = params.dig(:joins)

      payload['attrs'] = attrs unless  attrs.nil?
      payload['filter'] = filter unless  filter.nil?
      payload['joins'] = joins unless  joins.nil?

      result = Network.get(         host: name,
        url: format( '%s/v1/objects/hosts/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )

    end


    def exists_host?( name )

      result = hosts( name: name )

      result = JSON.parse( result ) if  result.is_a?( String )

      status = result.dig('status')

      return true if  !status.nil? && status == 200

      false

    end


    def host_objects( params = {} )

      attrs   = params.dig(:attrs)
      filter  = params.dig(:filter)
      joins   = params.dig(:joins)
      payload = {}

      if( attrs.nil? )
        attrs = %w[name state acknowledgement downtime_depth last_check]
      end

      payload['attrs'] = attrs unless  attrs.nil?

      payload['filter'] = filter unless  filter.nil?

      payload['joins'] = joins unless  joins.nil?

      result = Network.get(         host: nil,
        url: format( '%s/v1/objects/hosts', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload )

      JSON.pretty_generate( result )

    end


    def host_problems

      data     = host_objects
      problems = 0

      data = JSON.parse(data) if  data.is_a?(String)

      nodes = data.dig('nodes')

      nodes.each do |n|

        attrs           = n.last.dig('attrs')

        state           = attrs.dig('state')           || 0
        downtime_depth   = attrs.dig('downtime_depth')  || 0
        acknowledgement = attrs.dig('acknowledgement') || 0

        if( state != 0 && downtime_depth.zero? && acknowledgement.zero? )
          problems += 1
        end

      end

      problems

    end


    def problem_hosts( max_items = 5 )

      @host_problems = {}
      @host_problems_severity = {}

      host_data = host_objects

      host_data = JSON.parse( host_data ) if  host_data.is_a?(String)

#       logger.debug( host_data )

      host_data = host_data.dig('nodes')

      host_data.each do |_host,v|

        name  = v.dig('name')
        state = v.dig('attrs','state')

        next if  state.zero?

        @host_problems[name] = host_severity(v)
      end

      # get the count of problems
      #
      @host_problems.keys[1..max_items].each { |k,_v| @host_problems_severity[k] = @host_problems[k] }

      @host_problems_severity

    end

    # stolen from Icinga Web 2
    # ./modules/monitoring/library/Monitoring/Backend/Ido/Query/ServicestatusQuery.php
    #
    def host_severity( host )

      attrs           = host.dig('attrs')
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
      end

      severity
    end


  end

end
