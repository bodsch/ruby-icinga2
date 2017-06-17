
# frozen_string_literal: true

module Icinga2

  # namespace for status handling
  module Status

    # return Icinga2 Application data
    #
    # @example
    #    @icinga.application_data
    #
    # @return [Hash]
    #
    def application_data

      Network.get(host: nil,
        url: format( '%s/v1/status/IcingaApplication', @icinga_api_url_base ),
        headers: @headers,
        options: @options)

    end

    # return Icinga2 CIB
    #
    # @example
    #    @icinga.cib_data
    #
    # @return [Hash]
    #
    def cib_data

      Network.get(host: nil,
        url: format( '%s/v1/status/CIB', @icinga_api_url_base ),
        headers: @headers,
        options: @options)

    end

    # return Icinga2 API Listener
    #
    # @example
    #    @icinga.api_listener
    #
    # @return [Hash]
    #
    def api_listener

      Network.get(host: nil,
        url: format( '%s/v1/status/ApiListener', @icinga_api_url_base ),
        headers: @headers,
        options: @options)

    end

  end
end
