
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





    def listServices( params = {} )

      name = params.dig(:name)

      result = Network.get( {
        :host     => name,
        :url      => sprintf( '%s/v1/objects/services/%s', @icingaApiUrlBase, name ),
        :headers  => @headers,
        :options  => @options
      } )

      return JSON.pretty_generate( result )

    end


    def existsService?( name )

      result = self.listServices( { :name => name } )

      if( result.is_a?( String ) )
        result = JSON.parse( result )
      end

      logger.debug( result )

      status = result.dig('status')

      if( status != nil && status == 200 )
        return true
      end

      return false

    end

  end

end
