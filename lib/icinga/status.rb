
module Icinga

  module Status

    def applicationData()

      result = Network.get( {
        :host     => nil,
        :url      => sprintf( '%s/v1/status/IcingaApplication', @icingaApiUrlBase ),
        :headers  => @headers,
        :options  => @options
      })

      status = result.dig('status')

      return status

    end

  end

end
