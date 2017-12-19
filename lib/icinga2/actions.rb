
# frozen_string_literal: false

module Icinga2

  # namespace for action handling
  #
  # There are several actions available for Icinga 2 provided by the /v1/actions URL endpoint.
  #
  #
  # original API Documentation: https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#actions
  #
  module Actions

    # Process a check result for a host or a service.
    #
    # FUNCTION IS NOT IMPLEMENTED YET
    #
    # original Documentation: https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#process-check-result
    #
    # @param [Hash] params
    # @option params [Integer] exit_status For services: 0=OK, 1=WARNING, 2=CRITICAL, 3=UNKNOWN, for hosts: 0=OK, 1=CRITICAL.
    # @option params [String] plugin_output One or more lines of the plugin main output. Does not contain the performance data.
    # @option params [Array] performance_data The performance data.
    # @option params [Array] check_command The first entry should be the check commands path, then one entry for each command line option followed by an entry for each of its argument.
    # @option params [String] check_source Usually the name of the command_endpoint
    # @option params [Integer] execution_start The timestamp where a script/process started its execution.
    # @option params [Integer] execution_end The timestamp where a script/process ended its execution. This timestamp is used in features to determine e.g. the metric timestamp.
    # @option params [String] host_name
    # @option params [String] service_name
    # @option params [String] type
    # @option params [String] filter
    #
    # @example
    #   params = {
    #     host_name: 'example.localdomain',
    #     service_name: 'passive-ping6',
    #     exit_status: 2,
    #     plugin_output: 'PING CRITICAL - Packet loss = 100%',
    #     performance_data: [
    #       'rta=5000.000000ms;3000.000000;5000.000000;0.000000',
    #       'pl=100%;80;100;0'
    #     ],
    #     check_source: 'example.localdomain'
    #   }
    #   process_check_result(params)
    #
    #   params = {
    #     exit_status: 1,
    #     plugin_output: 'Host is not available.',
    #     type: 'Host',
    #     filter: 'host.name == "example.localdomain"'
    #   }
    #   process_check_result(params)
    #
    # @return [Hash] result
    #
    def process_check_result(params)

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing \'params\'') if( params.size.zero? )

      exit_status      = validate( params, required: true, var: 'exit_status', type: Integer )
      plugin_output    = validate( params, required: true, var: 'plugin_output', type: String )
      performance_data = validate( params, required: false, var: 'performance_data', type: Array )
      check_command    = validate( params, required: false, var: 'check_command', type: Array )
      check_source     = validate( params, required: false, var: 'check_source', type: String )
      execution_start  = validate( params, required: false, var: 'execution_start', type: Integer )
      execution_end    = validate( params, required: false, var: 'execution_end', type: String )

    end

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#reschedule-check
    def reschedule_check(params)

      # $ curl -k -s -u root:icinga -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/actions/reschedule-check' \
      # -d '{ "type": "Service", "filter": "service.name==\"ping6\"" }' | python -m json.tool
    end

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#send-custom-notification
    def send_custom_notification
    end

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#delay-notification
    def delay_notification
    end

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#acknowledge-problem
    def acknowledge_problem
    end

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#remove-acknowledgement
    def remove_acknowledgement
    end

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#add-comment
    def add_comment
    end

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#remove-comment
    def remove_comment
    end

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#schedule-downtime
    def schedule_downtime
    end

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#remove-downtime
    def remove_downtime
    end

    # Shuts down Icinga2.
    #
    # @example
    #    shutdown_process
    #
    # @return [Hash]
    #
    def shutdown_process
      post(
        url: format('%s/actions/shutdown-process', @icinga_api_url_base),
        headers: @headers,
        options: @options
      )
    end

    # Restarts Icinga2.
    #
    # @example
    #    restart_process
    #
    # @return [Hash]
    #
    def restart_process
      post(
        url: format('%s/actions/restart-process', @icinga_api_url_base),
        headers: @headers,
        options: @options
      )
    end

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#generate-ticket
    def generate_ticket
    end

  end
end
