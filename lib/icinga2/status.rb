
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

      data = Network.application_data(
        url: format( '%s/status/IcingaApplication', @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )

      unless( data.nil? )

        a_data = data.dig('icingaapplication','app')

        # version and revision
        @version, @revision = parse_version(a_data.dig('version'))

        #   - node_name
        @node_name = a_data.dig('node_name')

        #   - start_time
        @start_time = Time.at(a_data.dig('program_start').to_f)

        return data

      end

    end

    # return Icinga2 CIB
    #
    # @example
    #    @icinga.cib_data
    #
    # @return [Hash]
    #
    def cib_data

      data = Network.application_data(
        url: format( '%s/status/CIB', @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )

      c_data = data.clone

      unless( c_data.nil? )

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

        #   - services
        @services_ok           = c_data.dig('num_services_ok').to_i
        @services_warning      = c_data.dig('num_services_warning').to_i
        @services_critical     = c_data.dig('num_services_critical').to_i
        @services_unknown      = c_data.dig('num_services_unknown').to_i
        @services_in_downtime  = c_data.dig('num_services_in_downtime').to_i
        @services_acknowledged = c_data.dig('num_services_acknowledged').to_i

        #   - check stats
        @hosts_active_checks_1min     = c_data.dig('active_host_checks_1min')
        @hosts_passive_checks_1min    = c_data.dig('passive_host_checks_1min')
        @services_active_checks_1min  = c_data.dig('active_service_checks_1min')
        @services_passive_checks_1min = c_data.dig('passive_service_checks_1min')

      end

      data
    end

    #
    #
    #
    def status_data

      Network.application_data(
        url: format( '%s/status', @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )
    end

    # return Icinga2 API Listener
    #
    # @example
    #    @icinga.api_listener
    #
    # @return [Hash]
    #
    def api_listener

      Network.application_data(
        url: format( '%s/status/ApiListener', @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )
    end

    # return queue statistics from the api
    #
    # @example
    #    @icinga.work_queue_statistics
    #
    # @return [Hash]
    #
    def work_queue_statistics

      stats  = {}
      data   = Network.api_data(
        url: format( '%s/status', @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )

      return stats if data.nil?

      if( data.dig(:status).nil? )
        results = data.dig('results')

        json_rpc_data  = results.find { |k| k['name'] == 'ApiListener' }
        graphite_data  = results.find { |k| k['name'] == 'GraphiteWriter' }
        ido_mysql_data = results.find { |k| k['name'] == 'IdoMysqlConnection' }

        json_rpc_data  = json_rpc_data.dig('status', 'api', 'json_rpc')
        graphite_data  = graphite_data.dig('status', 'graphitewriter', 'graphite')
        ido_mysql_data = ido_mysql_data.dig('status', 'idomysqlconnection', 'ido-mysql')

        a = {}
        a['json_rpc']  = json_rpc_data  if(json_rpc_data.is_a?(Hash))
        a['graphite']  = graphite_data  if(graphite_data.is_a?(Hash))
        a['ido-mysql'] = ido_mysql_data if(ido_mysql_data.is_a?(Hash))

        key_list = %w[work_queue_item_rate query_queue_item_rate]

        a.each do |k,v|
          key_list.each do |key|
            if( v.include?( key ))
              attr_name = format('%s queue rate', k)
              stats[attr_name] = v[key].to_f.round(3)
            end
          end
        end
      end

      stats
    end


    # extract many datas from application_data and cib_data
    # and store them in global variables
    #
    def extract_data

      a_data = application_data

      if( a_data.is_a?(Hash) )

        a_data = a_data.dig('status','icingaapplication','app')

        unless( a_data.nil? )

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

        unless( c_data.nil? )

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
          @hosts_problems_down             = count_problems(h_objects, Icinga2::HOSTS_DOWN)

          # calculate host problems adjusted by handled problems
          # count togther handled host problems
#           @hosts_handled_problems          = @hosts_handled_warning_problems + @hosts_handled_critical_problems + @hosts_handled_unknown_problems
#           @hosts_down_adjusted             = @hosts_down - @hosts_handled_problems

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
          @services_problems                  = count_services_with_problems
          @services_handled_warning_problems  = count_problems(s_objects, Icinga2::SERVICE_STATE_WARNING)
          @services_handled_critical_problems = count_problems(s_objects, Icinga2::SERVICE_STATE_CRITICAL)
          @services_handled_unknown_problems  = count_problems(s_objects, Icinga2::SERVICE_STATE_UNKNOWN)

          # calculate service problems adjusted by handled problems
          @services_warning_adjusted  = @services_warning - @services_handled_warning_problems
          @services_critical_adjusted = @services_critical - @services_handled_critical_problems
          @services_unknown_adjusted  = @services_unknown - @services_handled_unknown_problems


          #   - check stats
          @hosts_active_checks_1min     = c_data.dig('active_host_checks_1min')
          @hosts_passive_checks_1min    = c_data.dig('passive_host_checks_1min')
          @services_active_checks_1min  = c_data.dig('active_service_checks_1min')
          @services_passive_checks_1min = c_data.dig('passive_service_checks_1min')

          @count_services_with_problems, @count_services_with_problems_severity = list_services_with_problems
        end
      end
    end


#     def version
#
#       data = application_data
#
#       puts data
#
#       # a_data = a_data.dig('status','icingaapplication','app')
#
#     end
#
#     def revision
#
#       data = application_data
#
#       puts data
#
#       # a_data = a_data.dig('status','icingaapplication','app')
#
#
#     end

  end
end
