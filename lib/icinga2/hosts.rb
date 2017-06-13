
# frozen_string_literal: true
module Icinga2

  module Hosts

    def addHost( params = {} )

      name             = params.dig(:name)
      fqdn             = params.dig(:fqdn)
      displayName      = params.dig(:display_name) || name
      notifications    = params.dig(:enable_notifications) || false
      maxCheckAttempts = params.dig(:max_check_attempts) || 3
      checkInterval    = params.dig(:check_interval) || 60
      retryInterval    = params.dig(:retry_interval) || 45
      notes            = params.dig(:notes)
      notesUrl         = params.dig(:notes_url)
      actionUrl        = params.dig(:action_url)
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
          'display_name'         => displayName,
          'max_check_attempts'   => maxCheckAttempts.to_i,
          'check_interval'       => checkInterval.to_i,
          'retry_interval'       => retryInterval.to_i,
          'enable_notifications' => notifications,
          'action_url'           => actionUrl,
          'notes'                => notes,
          'notes_url'            => notesUrl
        }
      }

      payload['attrs']['vars'] = vars unless  vars.empty? 

      if( @icingaCluster == true && !@icingaSatellite.nil? )
        payload['attrs']['zone'] = @icingaSatellite
      end

      logger.debug( JSON.pretty_generate( payload ) )

      result = Network.put(         host: name,
        url: format( '%s/v1/objects/hosts/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options,
        payload: payload )

      JSON.pretty_generate( result )

    end


    def deleteHost( params = {} )

      name = params.dig(:name)

      if( name.nil? )

        return {
          status: 404,
          message: 'missing host name'
        }
      end

      result = Network.delete(         host: name,
        url: format( '%s/v1/objects/hosts/%s?cascade=1', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )

    end


    def listHosts( params = {} )

      name   = params.dig(:name)
      attrs  = params.dig(:attrs)
      filter = params.dig(:filter)
      joins  = params.dig(:joins)

      payload['attrs'] = attrs unless  attrs.nil? 

      payload['filter'] = filter unless  filter.nil? 

      payload['joins'] = joins unless  joins.nil? 

      result = Network.get(         host: name,
        url: format( '%s/v1/objects/hosts/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )

    end


    def existsHost?( name )

      result = listHosts( name: name )

      result = JSON.parse( result ) if  result.is_a?( String ) 

      status = result.dig('status')

      return true if  !status.nil? && status == 200 

      false

    end


    def hostObjects( params = {} )

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
        url: format( '%s/v1/objects/hosts', @icingaApiUrlBase ),
        headers: @headers,
        options: @options,
        payload: payload )

      JSON.pretty_generate( result )

    end


    def hostProblems

      data     = hostObjects
      problems = 0

      data = JSON.parse(data) if  data.is_a?(String) 

      nodes = data.dig('nodes')

      nodes.each do |n|

        attrs           = n.last.dig('attrs')

        state           = attrs.dig('state')           || 0
        downtimeDepth   = attrs.dig('downtime_depth')  || 0
        acknowledgement = attrs.dig('acknowledgement') || 0

        if( state != 0 && downtimeDepth == 0 && acknowledgement == 0 )
          problems += 1
        end

      end

      problems

    end


    def problemHosts( max_items = 5 )

      count = 0
      @hostProblems = {}
      @hostProblemsSeverity = {}

      hostData = hostObjects

      hostData = JSON.parse( hostData ) if  hostData.is_a?(String) 

#       logger.debug( hostData )

      hostData = hostData.dig('nodes')

      hostData.each do |_host,v|

        name  = v.dig('name')
        state = v.dig('attrs','state')

        next if  state == 0 

        @hostProblems[name] = hostSeverity(v)
      end

      # get the count of problems
      #
      @hostProblems.keys[1..max_items].each { |k,_v| @hostProblemsSeverity[k] = @hostProblems[k] }

#       @hostProblems.each do |k,v|
#
#         if( count >= max_items )
#           break
#         end
#
#         @hostProblemsSeverity[k] = v
#
#         count += 1
#       end

      @hostProblemsSeverity

    end

    # stolen from Icinga Web 2
    # ./modules/monitoring/library/Monitoring/Backend/Ido/Query/ServicestatusQuery.php
    #
    def hostSeverity( host )

      attrs = host['attrs']

      severity = 0

      if attrs['state'] == 0
        severity += 16 if object_has_been_checked(host)

        severity += if attrs['acknowledgement'] != 0
          2
        elsif attrs['downtime_depth'] > 0
          1
        else
          4
                    end
      else
        severity += if object_has_been_checked(host)
          16
        elsif attrs['state'] == 1
          32
        elsif attrs['state'] == 2
          64
        else
          256
                    end

        severity += if attrs['acknowledgement'] != 0
          2
        elsif attrs['downtime_depth'] > 0
          1
        else
          4
                    end
      end

      severity

    end


  end

end
