
# frozen_string_literal: true
module Icinga2

  module Status

    def applicationData

      result = Network.get(         host: nil,
        url: format( '%s/v1/status/IcingaApplication', @icingaApiUrlBase ),
        headers: @headers,
        options: @options)

#       status = result.dig('status')

      JSON.pretty_generate( result )

    end


    def CIBData

      result = Network.get(         host: nil,
        url: format( '%s/v1/status/CIB', @icingaApiUrlBase ),
        headers: @headers,
        options: @options)

#       status = result.dig('status')

      JSON.pretty_generate( result )
    end

    def apiListener

      result = Network.get(         host: nil,
        url: format( '%s/v1/status/ApiListener', @icingaApiUrlBase ),
        headers: @headers,
        options: @options)

#       status = result.dig('status')

      JSON.pretty_generate( result )
    end

  end

end
