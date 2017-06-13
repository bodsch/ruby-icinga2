
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

      if( name == nil )

        return {
          :status  => 404,
          :message => 'missing host name'
        }
      end

      if( fqdn == nil )
        # build FQDN
        fqdn = Socket.gethostbyname( name ).first
      end

      payload = {
        "templates" => [ "generic-host" ],
        "attrs"     => {
          "address"              => fqdn,
          "display_name"         => displayName,
          "max_check_attempts"   => maxCheckAttempts.to_i,
          "check_interval"       => checkInterval.to_i,
          "retry_interval"       => retryInterval.to_i,
          "enable_notifications" => notifications,
          "action_url"           => actionUrl,
          "notes"                => notes,
          "notes_url"            => notesUrl
        }
      }

      if( ! vars.empty? )
        payload['attrs']['vars'] = vars
      end

      if( @icingaCluster == true && @icingaSatellite != nil )
        payload['attrs']['zone'] = @icingaSatellite
      end

      logger.debug( JSON.pretty_generate( payload ) )

      result = Network.put( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/hosts/%s', @icingaApiUrlBase, name ),
        :headers => @headers,
        :options => @options,
        :payload => payload
      } )

      return JSON.pretty_generate( result )

    end


    def deleteHost( params = {} )

      name = params.dig(:name)

      if( name == nil )

        return {
          :status  => 404,
          :message => 'missing host name'
        }
      end

      result = Network.delete( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/hosts/%s?cascade=1', @icingaApiUrlBase, name ),
        :headers => @headers,
        :options => @options
      } )

      return JSON.pretty_generate( result )

    end


    def listHosts( params = {} )

      name   = params.dig(:name)
      attrs  = params.dig(:attrs)
      filter = params.dig(:filter)
      joins  = params.dig(:joins)

      if( attrs != nil )
        payload['attrs'] = attrs
      end

      if( filter != nil )
        payload['filter'] = filter
      end

      if( joins != nil )
        payload['joins'] = joins
      end

      result = Network.get( {
        :host => name,
        :url  => sprintf( '%s/v1/objects/hosts/%s', @icingaApiUrlBase, name ),
        :headers  => @headers,
        :options  => @options
      } )

      return JSON.pretty_generate( result )

    end


    def existsHost?( name )

      result = self.listHosts( { :name => name } )

      if( result.is_a?( String ) )
        result = JSON.parse( result )
      end

      status = result.dig('status')

      if( status != nil && status == 200 )
        return true
      end

      return false

    end


    def hostObjects( params = {} )

      attrs   = params.dig(:attrs)
      filter  = params.dig(:filter)
      joins   = params.dig(:joins)
      payload = {}

      if( attrs == nil )
        attrs = ['name','state','acknowledgement','downtime_depth','last_check']
      end

      if( attrs != nil )
        payload['attrs'] = attrs
      end

      if( filter != nil )
        payload['filter'] = filter
      end

      if( joins != nil )
        payload['joins'] = joins
      end

      result = Network.get( {
        :host     => nil,
        :url      => sprintf( '%s/v1/objects/hosts', @icingaApiUrlBase ),
        :headers  => @headers,
        :options  => @options,
        :payload  => payload
      } )

      return JSON.pretty_generate( result )

    end


    def hostProblems()

      data     = self.hostObjects()
      problems = 0

      if( data.is_a?(String) )
        data = JSON.parse(data)
      end

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

      return problems

    end


    def problemHosts( max_items = 5 )

      count = 0
      @hostProblems = {}
      @hostProblemsSeverity = {}

      hostData = self.hostObjects()

      if( hostData.is_a?(String) )

        hostData = JSON.parse( hostData )
      end

#       logger.debug( hostData )

      hostData = hostData.dig('nodes')

      hostData.each do |host,v|

        name  = v.dig('name')
        state = v.dig('attrs','state')

        if( state == 0 )
          next
        end

        @hostProblems[name] = self.hostSeverity(v)
      end

      # get the count of problems
      #
      @hostProblems.keys[1..max_items].each { |k,v| @hostProblemsSeverity[k] = @hostProblems[k] }

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

      return @hostProblemsSeverity

    end

    # stolen from Icinga Web 2
    # ./modules/monitoring/library/Monitoring/Backend/Ido/Query/ServicestatusQuery.php
    #
    def hostSeverity( host )

      attrs = host["attrs"]

      severity = 0

      if (attrs["state"] == 0)
        if (object_has_been_checked(host))
          severity += 16
        end

        if (attrs["acknowledgement"] != 0)
          severity += 2
        elsif (attrs["downtime_depth"] > 0)
          severity += 1
        else
          severity += 4
        end
      else
        if (object_has_been_checked(host))
          severity += 16
        elsif (attrs["state"] == 1)
          severity += 32
        elsif (attrs["state"] == 2)
          severity += 64
        else
          severity += 256
        end

        if (attrs["acknowledgement"] != 0)
          severity += 2
        elsif (attrs["downtime_depth"] > 0)
          severity += 1
        else
          severity += 4
        end
      end

      return severity

    end


  end

end
