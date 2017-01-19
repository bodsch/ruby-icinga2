
module Icinga

  module Application

    def applicationData()

      result = Network.get( {
        :host     => nil,
        :url      => sprintf( '%s/v1/status/IcingaApplication', @icingaApiUrlBase ),
        :headers  => @headers,
        :options  => @options
      })

      logger.debug( result )
      logger.debug( result.dig('results').first.dig('status') )

      return result


#       apiUrl     = sprintf( '%s/v1/status/IcingaApplication', @icingaApiUrlBase )
#       restClient = RestClient::Resource.new( URI.encode( apiUrl ), @options )
#       data       = JSON.parse( restClient.get( @headers ).body )
#       result     = data['results'][0]['status'] # there's only one row
#
#       return result

    end

  end
end
