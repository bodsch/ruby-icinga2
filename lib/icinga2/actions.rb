
# frozen_string_literal: false

module Icinga2

  # namespace for hostgroup handling
  module Actions

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#reschedule-check
    def reschedule_check(params)

      # $ curl -k -s -u root:icinga -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/actions/reschedule-check' \
      # -d '{ "type": "Service", "filter": "service.name==\"ping6\"" }' | python -m json.tool
    end


    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#process-check-result
    def process_check_result
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

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#shutdown-process
    def shutdown_process
      post(
        url: format('%s/actions/shutdown-process', @icinga_api_url_base),
        headers: @headers,
        options: @options
      )
    end

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#restart-process
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
