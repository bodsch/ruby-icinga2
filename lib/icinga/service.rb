
module Icinga

  module Service

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

#       fqdn = Socket.gethostbyname( host ).first

#       restClient = RestClient::Resource.new(
#         URI.encode( sprintf( '%s/v1/objects/hosts/%s', @icingaApiUrlBase, host ) ),
#         @options
#       )

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

#         begin
#
#           restClient = RestClient::Resource.new(
#             URI.encode( sprintf( '%s/v1/objects/services/%s!%s', @icingaApiUrlBase, host, s ) ),
#             @options
#           )
#
#
#
#
#
#           data = restClient.put(
#             JSON.generate( ( payload ) ),
#             @headers
#           )
#         rescue RestClient::ExceptionWithResponse => e
#
#           error  = JSON.parse( e.response )
#
#           logger.error( error )
#
#         end

      end

    end

  end

end
