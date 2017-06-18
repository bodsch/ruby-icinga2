
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

    # extract many datas from application_data and cib_data
    # and store them in global variables
    #
    def extract_data

      a_data = application_data

      if( a_data.is_a?(Hash) )

        a_data = a_data.dig('status','icingaapplication','app')

        if( !a_data.nil? )

          # extract
          #   - version
          @version, @revision = parse_version(a_data.dig('version'))

          #   - node_name
          @node_name = a_data.dig('node_name')

          #   - start_time
          @start_time = Time.at(a_data.dig('program_start').to_f)
        end
      end

      c_data = cib_data

      if( c_data.is_a?(Hash) )

        c_data = c_data.dig('status')

        if( !c_data.nil? )

          # extract
          #   - uptime
          uptime   = c_data.dig('uptime').round(2)
          @uptime  = Time.at(uptime).utc.strftime('%H:%M:%S')

          #   - avg_latency / avg_execution_time
          @avg_latency        = c_data.dig('avg_latency').round(2)
          @avg_execution_time = c_data.dig('avg_execution_time').round(2)

          #   - hosts
          @hosts_up           = c_data.dig('num_hosts_up').to_i
          @hosts_down         = c_data.dig('num_hosts_down').to_i
          @hosts_in_downtime  = c_data.dig('num_hosts_in_downtime').to_i
          @hosts_acknowledged = c_data.dig('num_hosts_acknowledged').to_i

          h_objects = host_objects
          all_hosts = h_objects.dig(:nodes)

          @hosts_all                       = all_hosts.size
          @hosts_problems                  = host_problems
          @hosts_handled_warning_problems  = handled_problems(all_hosts, Icinga2::HANDLED_WARNING)
          @hosts_handled_critical_problems = handled_problems(all_hosts, Icinga2::HANDLED_CRITICAL)
          @hosts_handled_unknown_problems  = handled_problems(all_hosts, Icinga2::HANDLED_UNKNOWN)

          # calculate host problems adjusted by handled problems
          # count togther handled host problems
          @hosts_handled_problems          = @hosts_handled_warning_problems + @hosts_handled_critical_problems + @hosts_handled_unknown_problems
          @hosts_down_adjusted             = @hosts_down - @hosts_handled_problems

          #   - services
          @services_ok           = c_data.dig('num_services_ok').to_i
          @services_warning      = c_data.dig('num_services_warning').to_i
          @services_critical     = c_data.dig('num_services_critical').to_i
          @services_unknown      = c_data.dig('num_services_unknown').to_i
          @services_in_downtime  = c_data.dig('num_services_in_downtime').to_i
          @services_acknowledged = c_data.dig('num_services_acknowledged').to_i

          s_objects = service_objects
          all_services = s_objects.dig(:nodes)

          @services_all                       = all_services.size
          @services_problems                  = service_problems
          @services_handled_warning_problems  = handled_problems(all_services, Icinga2::HANDLED_WARNING)
          @services_handled_critical_problems = handled_problems(all_services, Icinga2::HANDLED_CRITICAL)
          @services_handled_unknown_problems  = handled_problems(all_services, Icinga2::HANDLED_UNKNOWN)

          # calculate service problems adjusted by handled problems
          @services_warning_adjusted  = @services_warning - @services_handled_warning_problems
          @services_critical_adjusted = @services_critical - @services_handled_critical_problems
          @services_unknown_adjusted  = @services_unknown - @services_handled_unknown_problems


          #   - check stats
          @hosts_active_checks_1min     = c_data.dig('active_host_checks_1min')
          @hosts_passive_checks_1min    = c_data.dig('passive_host_checks_1min')
          @services_active_checks_1min  = c_data.dig('active_service_checks_1min')
          @services_passive_checks_1min = c_data.dig('passive_service_checks_1min')
        end
      end
    end
  end
end
