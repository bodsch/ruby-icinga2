
module Icinga

  module Host

    def addHost( params = {}, host = nil, vars = {} )

      code        = nil
      result      = {}

      host = params.dig(:host) || nil
      vars = params.dig(:vars) || {}

      if( host == nil )

        return {
          :status  => 500,
          :message => 'internal Server Error'
        }
      end

      status      = 0
      name        = host
      message     = 'undefined'

      @headers['X-HTTP-Method-Override'] = 'PUT'

      # build FQDN
      fqdn = Socket.gethostbyname( host ).first

      payload = {
        "templates" => [ "generic-host" ],
        "attrs" => {
          "address"      => fqdn,
          "display_name" => host
        }
      }

      if( ! vars.empty? )
        payload['attrs']['vars'] = vars
      end

      logger.debug( JSON.pretty_generate( payload ) )



      result = Network.put( {
        :host    => host,
        :url     => sprintf( '%s/v1/objects/hosts/%s', @icingaApiUrlBase, host ),
        :headers => @headers,
        :options => @options,
        :payload => payload
      })

      logger.debug( result )

      exit 2



#       restClient = RestClient::Resource.new(
#         URI.encode( sprintf( '%s/v1/objects/hosts/%s', @icingaApiUrlBase, host ) ),
#         @options
#       )
#
#       begin
#         data = restClient.put(
#           JSON.generate( payload ),
#           @headers
#         )
#
#         data   = JSON.parse( data )
#         result = data['results'][0] ? data['results'][0] : nil
#
#         if( result != nil )
#
#           status  = 200
#           name    = host
#           message = result['status']
#
#         end
#
#       rescue RestClient::ExceptionWithResponse => e
#
#         error  = JSON.parse( e.response )
#
#         if( error['results'] )
#
#           result  = error['results'][0] ? error['results'][0] : error
#           status  = result['code'].to_i
#           message = result['status']
#         else
#
#           status  = error['error'].to_i
#           message = error['status']
#         end
#
#         status      = status
#         name        = host
#         message     = message
#
#       end
#
#       @status = status
#
#       result = {
#         :status      => status,
#         :name        => name,
#         :message     => message
#       }
#
#       return result

    end

    # TODO
    # funktioniert nur, wenn der Host bereits existiert
    def deleteHost( host )

      status      = 0
      name        = host
      message     = 'undefined'

#       @headers['X-HTTP-Method-Override'] = 'DELETE'

#       @headers.delete( 'X-HTTP-Method-Override' )

      result = Network.delete( {
        :host    => host,
        :url     => sprintf( '%s/v1/objects/hosts/%s?cascade=1', @icingaApiUrlBase, host ),
        :headers => @headers,
        :options => @options
      })


      logger.debug( result )

      exit 2




#       restClient = RestClient::Resource.new(
#         URI.encode( sprintf( '%s/v1/objects/hosts/%s?cascade=1', @icingaApiUrlBase, host ) ),
#         @options
#       )
#
#       begin
#         data   = restClient.get( @headers )
#         data   = JSON.parse( data )
#         result = data['results'][0] ? data['results'][0] : nil
#
#         if( result != nil )
#
#           status  = 200
#           name    = host
#           message = result['status']
#
#         end
#       rescue => e
#
#         # TODO
#         # bessere fehlerbehandlung, hier kommt es immer mal wieder zu problemen!
#         error  = JSON.parse( e.response )
#
#         if( error['results'] )
#
#           result  = error['results'][0] ? error['results'][0] : error
#           status  = result['code'].to_i
#           message = result['status']
#         else
#
#           status  = error['error'].to_i
#           message = error['status']
#         end
#
#         status      = status
#         name        = host
#         message     = message
#
#       rescue e
#         logger.error( e )
#
#       end
#
#       @status = status
#
#       result = {
#         :status      => status,
#         :name        => name,
#         :message     => message
#       }
#
#       return result

    end


    def listHost( params = {} )

      code        = nil
      result      = {}

      host = params.dig(:host) || nil

      result = Network.get( {
        :host => host,
        :url  => sprintf( '%s/v1/objects/hosts/%s', @icingaApiUrlBase, host ),
        :headers  => @headers,
        :options  => @options
      } )

      logger.debug( JSON.pretty_generate( result ) )

      return result

    end

  end

end
