
module Icinga

  module Services

    def addServices( host, services = {} )

      def updateHost( hash, host )

        hash.each do |k, v|

          if( k == "host" && v.is_a?( String ) )
            v.replace( host )

          elsif( v.is_a?( Hash ) )
            self.updateHost( v, host )

          elsif( v.is_a?(Array) )

            v.flatten.each { |x| self.updateHost( x, host ) if x.is_a?( Hash ) }
          end
        end

        hash
      end

      services.each do |s,v|

        payload = {
          "templates" => [ "generic-service" ],
          "attrs"     => updateHost( v, host )
        }

        logger.debug( s )
        logger.debug( v.to_json )

        logger.debug( JSON.pretty_generate( payload ) )

        result = Network.put( {
          :host    => host,
          :url     => sprintf( '%s/v1/objects/services/%s!%s', @icingaApiUrlBase, host, s ),
          :headers => @headers,
          :options => @options,
          :payload => payload
        })

        logger.debug( result )

      end

    end



    def unhandledServices( params = {} )

      # taken from https://blog.netways.de/2016/11/18/icinga-2-api-cheat-sheet/
      # 5) Anzeige aller Services die unhandled sind und weder in Downtime, noch acknowledged sind
      # /usr/bin/curl -k -s -u 'root:icinga' -H 'X-HTTP-Method-Override: GET' -X POST 'https://127.0.0.1:5665/v1/objects/services' -d '{ "attrs": [ "__name", "state", "downtime_depth", "acknowledgement" ], "filter": "service.state != ServiceOK && service.downtime_depth == 0.0 && service.acknowledgement == 0.0" }''' | jq

    end

    def listServices( params = {} )

      name    = params.dig(:host)
      service = params.dig(:service)

      if( service == nil )
        url = sprintf( '%s/v1/objects/services/%s', @icingaApiUrlBase, name )
      else
        url = sprintf( '%s/v1/objects/services/%s!%s', @icingaApiUrlBase, name, service )
      end

      result = Network.get( {
        :host     => name,
        :url      => url,
        :headers  => @headers,
        :options  => @options
      } )

      return JSON.pretty_generate( result )

    end


    def existsService?( params = {} )

      host    = params.dig(:host)
      service = params.dig(:service)

      if( host == nil )

        return {
          :status  => 404,
          :message => 'missing host name'
        }
      end

      result = self.listServices( { :host => host, :service => service } )

      if( result.is_a?( String ) )
        result = JSON.parse( result )
      end

      status = result.dig('status')

      if( status != nil && status == 200 )
        return true
      end

      return false

    end

  end

end
