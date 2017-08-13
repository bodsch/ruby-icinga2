
# frozen_string_literal: true

module Icinga2

  # namespace for status handling
  module Status



    # extract many datas from application_data and cib_data
    # and store them in global variables
    #
#    def extract_data
#
#      a_data = application_data
#
#      if( a_data.is_a?(Hash) )
#
#        a_data = a_data.dig('status','icingaapplication','app')
#
#        unless( a_data.nil? )
#
#          # extract
#          #   - version
#          @version, @revision = parse_version(a_data.dig('version'))
#
#          #   - node_name
#          @node_name = a_data.dig('node_name')
#
#          #   - start_time
#          @start_time = Time.at(a_data.dig('program_start').to_f)
#        end
#      end
#
#      c_data = cib_data
#
#      return nil unless( c_data.is_a?(Hash) )
#
#      c_data = c_data.dig('status')
#
#      return nil if( c_data.nil? )
#
#      # extract
#      #   - uptime
#      uptime   = c_data.dig('uptime').round(2)
#      @uptime  = Time.at(uptime).utc.strftime('%H:%M:%S')
#
#      #   - avg_latency / avg_execution_time
#      @avg_latency        = c_data.dig('avg_latency').round(2)
#      @avg_execution_time = c_data.dig('avg_execution_time').round(2)
#
#      #   - hosts
#      @hosts_up           = c_data.dig('num_hosts_up').to_i
#      @hosts_down         = c_data.dig('num_hosts_down').to_i
#      @hosts_in_downtime  = c_data.dig('num_hosts_in_downtime').to_i
#      @hosts_acknowledged = c_data.dig('num_hosts_acknowledged').to_i
#
#      h_objects = host_objects
#      all_hosts = h_objects.dig(:nodes)
#
#      @hosts_all                       = all_hosts.size
#      @hosts_problems                  = host_problems
#      @hosts_problems_down             = count_problems(h_objects, Icinga2::HOSTS_DOWN)
#
#      # calculate host problems adjusted by handled problems
#      # count togther handled host problems
##       @hosts_handled_problems          = @hosts_handled_warning_problems + @hosts_handled_critical_problems + @hosts_handled_unknown_problems
##       @hosts_down_adjusted             = @hosts_down - @hosts_handled_problems
#
#      #   - services
#      @services_ok           = c_data.dig('num_services_ok').to_i
#      @services_warning      = c_data.dig('num_services_warning').to_i
#      @services_critical     = c_data.dig('num_services_critical').to_i
#      @services_unknown      = c_data.dig('num_services_unknown').to_i
#      @services_in_downtime  = c_data.dig('num_services_in_downtime').to_i
#      @services_acknowledged = c_data.dig('num_services_acknowledged').to_i
#
#      s_objects = service_objects
#      all_services = s_objects.dig(:nodes)
#
#      @services_all                       = all_services.size
#      @services_problems                  = count_services_with_problems
#      @services_handled_warning_problems  = count_problems(s_objects, Icinga2::SERVICE_STATE_WARNING)
#      @services_handled_critical_problems = count_problems(s_objects, Icinga2::SERVICE_STATE_CRITICAL)
#      @services_handled_unknown_problems  = count_problems(s_objects, Icinga2::SERVICE_STATE_UNKNOWN)
#
#      # calculate service problems adjusted by handled problems
#      @services_warning_adjusted  = @services_warning - @services_handled_warning_problems
#      @services_critical_adjusted = @services_critical - @services_handled_critical_problems
#      @services_unknown_adjusted  = @services_unknown - @services_handled_unknown_problems
#
#
#      #   - check stats
#      @hosts_active_checks_1min     = c_data.dig('active_host_checks_1min')
#      @hosts_passive_checks_1min    = c_data.dig('passive_host_checks_1min')
#      @services_active_checks_1min  = c_data.dig('active_service_checks_1min')
#      @services_passive_checks_1min = c_data.dig('passive_service_checks_1min')
#
#      @count_services_with_problems, @count_services_with_problems_severity = list_services_with_problems
#
#    end


  end
end
