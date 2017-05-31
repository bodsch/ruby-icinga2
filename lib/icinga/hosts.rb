
module Icinga

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


    def hostObjects()



    end

  def getHostObjects(attrs = nil, filter = nil, joins = nil)
    apiUrl = sprintf('%s/objects/hosts', @apiUrlBase)
    restClient = RestClient::Resource.new(URI.encode(apiUrl), @options)

    @headers["X-HTTP-Method-Override"] = "GET"
    requestBody = {}

    if (attrs)
      requestBody["attrs"] = attrs
    end

    if (filter)
      requestBody["filter"] = filter
    end

    if (joins)
      requestBody["joins"] = joins
    end

    payload = JSON.generate(requestBody)
    res = restClient.post(payload, @headers)
    body = res.body
    data = JSON.parse(body)
    return data['results']
  end


  end

end
