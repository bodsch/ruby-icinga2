
module Icinga2

  module Status

    def applicationData()

      result = Network.get( {
        :host     => nil,
        :url      => sprintf( '%s/v1/status/IcingaApplication', @icingaApiUrlBase ),
        :headers  => @headers,
        :options  => @options
      })

#       status = result.dig('status')

      return JSON.pretty_generate( result )

    end


    def CIBData()

      result = Network.get( {
        :host     => nil,
        :url      => sprintf( '%s/v1/status/CIB', @icingaApiUrlBase ),
        :headers  => @headers,
        :options  => @options
      })

#       status = result.dig('status')

      return JSON.pretty_generate( result )
    end

    def apiListener()

      result = Network.get( {
        :host     => nil,
        :url      => sprintf( '%s/v1/status/ApiListener', @icingaApiUrlBase ),
        :headers  => @headers,
        :options  => @options
      })

#       status = result.dig('status')

      return JSON.pretty_generate( result )
    end

  end

end
