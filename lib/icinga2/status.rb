
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

      result = Network.get(host: nil,
        url: format( '%s/v1/status/IcingaApplication', @icinga_api_url_base ),
        headers: @headers,
        options: @options)

      app_data = result.dig('status','icingaapplication','app')

      # extract
      #   - version
      @version, @revision = parse_version(app_data.dig('version'))

      #   - node_name
      @node_name = app_data.dig('node_name')

      #   - start_time
      @start_time = Time.at(app_data.dig('program_start').to_f)

      result

    end

    # return Icinga2 CIB
    #
    # @example
    #    @icinga.cib_data
    #
    # @return [Hash]
    #
    def cib_data

      result = Network.get(host: nil,
        url: format( '%s/v1/status/CIB', @icinga_api_url_base ),
        headers: @headers,
        options: @options)

      cib_data = result.dig('status')

      # extract
      #   - uptime
      uptime   = cib_data.dig('uptime').round(2)
      @uptime  = Time.at(uptime).utc.strftime('%H:%M:%S')

      #   - avg_latency / avg_execution_time
      @avg_latency        = cib_data.dig('avg_latency').round(2)
      @avg_execution_time = cib_data.dig('avg_execution_time').round(2)

      #   - hosts
      @hosts_up           = cib_data.dig('num_hosts_up').to_i
      @hosts_down         = cib_data.dig('num_hosts_down').to_i
      @hosts_in_downtime  = cib_data.dig('num_hosts_in_downtime').to_i
      @hosts_acknowledged = cib_data.dig('num_hosts_acknowledged').to_i

      #   - services
      @services_ok           = cib_data.dig('num_services_ok').to_i
      @services_warning      = cib_data.dig('num_services_warning').to_i
      @services_critical     = cib_data.dig('num_services_critical').to_i
      @services_unknown      = cib_data.dig('num_services_unknown').to_i
      @services_in_downtime  = cib_data.dig('num_services_in_downtime').to_i
      @services_acknowledged = cib_data.dig('num_services_acknowledged').to_i

      #   - check stats
      @hosts_active_checks_1min     = cib_data.dig('active_host_checks_1min')
      @hosts_passive_checks_1min    = cib_data.dig('passive_host_checks_1min')
      @services_active_checks_1min  = cib_data.dig('active_service_checks_1min')
      @services_passive_checks_1min = cib_data.dig('passive_service_checks_1min')

      result
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
