
# frozen_string_literal: true

module Icinga2

  #
  #
  #
  module Status

    #
    #
    #
    def application_data

      result = Network.get(host: nil,
        url: format( '%s/v1/status/IcingaApplication', @icinga_api_url_base ),
        headers: @headers,
        options: @options)

      JSON.pretty_generate( result )

    end

    #
    #
    #
    def cib_data

      result = Network.get(host: nil,
        url: format( '%s/v1/status/CIB', @icinga_api_url_base ),
        headers: @headers,
        options: @options)

      JSON.pretty_generate( result )
    end

    #
    #
    #
    def api_listener

      result = Network.get(host: nil,
        url: format( '%s/v1/status/ApiListener', @icinga_api_url_base ),
        headers: @headers,
        options: @options)

      JSON.pretty_generate( result )
    end

  end
end
