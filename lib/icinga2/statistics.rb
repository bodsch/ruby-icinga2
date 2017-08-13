# frozen_string_literal: true
#

module Icinga2

  # namespace for icinga2 statistics
  module Statistics


    # return statistic data for latency and execution_time
    #
    # @example
    #    @icinga.cib_data
    #    @icinga.average_statistics
    #
    # @return [Array] (avg_latency, avg_execution_time)
    #
    def average_statistics
      avg_latency        = @avg_latency.nil?        ? 0 : @avg_latency
      avg_execution_time = @avg_execution_time.nil? ? 0 : @avg_execution_time

      [avg_latency.to_s, avg_execution_time.to_s]
    end

    # return statistic data for intervall data
    #
    # @example
    #    @icinga.cib_data
    #    @icinga.interval_statistics
    #
    # @return [Array] (hosts_active_checks, hosts_passive_checks, services_active_checks, services_passive_checks)
    #
    def interval_statistics

      # take a look into https://github.com/Icinga/pkg-icinga2-debian/blob/master/lib/icinga/cib.cpp

      hosts_active_checks     = @hosts_active_checks_1min.nil?     ? 0 : @hosts_active_checks_1min
      hosts_passive_checks    = @hosts_passive_checks_1min.nil?    ? 0 : @hosts_passive_checks_1min
      services_active_checks  = @services_active_checks_1min.nil?  ? 0 : @services_active_checks_1min
      services_passive_checks = @services_passive_checks_1min.nil? ? 0 : @services_passive_checks_1min

      [hosts_active_checks, hosts_passive_checks, services_active_checks, services_passive_checks]
    end

    # return statistic data for services
    #
    # @example
    #    @icinga.cib_data
    #    ok, warning, nil, nil, pending, nil, nil = @icinga.service_statistics
    #
    # @return [Array] (services_ok, services_warning, services_critical,
    #                  services_unknown, services_pending,
    #                  services_in_downtime, services_acknowledged)
    #
    def service_statistics

      services_ok           = @services_ok.nil?           ? 0 : @services_ok
      services_warning      = @services_warning.nil?      ? 0 : @services_warning
      services_critical     = @services_critical.nil?     ? 0 : @services_critical
      services_unknown      = @services_unknown.nil?      ? 0 : @services_unknown
      services_pending      = @services_pending.nil?      ? 0 : @services_pending
      services_in_downtime  = @services_in_downtime.nil?  ? 0 : @services_in_downtime
      services_acknowledged = @services_acknowledged.nil? ? 0 : @services_acknowledged

      [services_ok, services_warning, services_critical, services_unknown, services_pending,
       services_in_downtime, services_acknowledged]
    end

    # return statistic data for hosts
    #
    # @example
    #    @icinga.cib_data
    #    up, down, pending, unreachable, in_downtime, ack = @icinga.host_statistics
    #
    # @return [Array] (hosts_up, hosts_down, hosts_pending, hosts_unreachable, hosts_in_downtime, hosts_acknowledged)
    #
    def host_statistics

      hosts_up           = @hosts_up.nil?           ? 0 : @hosts_up
      hosts_down         = @hosts_down.nil?         ? 0 : @hosts_down
      hosts_pending      = @hosts_pending.nil?      ? 0 : @hosts_pending
      hosts_unreachable  = @hosts_unreachable.nil?  ? 0 : @hosts_unreachable
      hosts_in_downtime  = @hosts_in_downtime.nil?  ? 0 : @hosts_in_downtime
      hosts_acknowledged = @hosts_acknowledged.nil? ? 0 : @hosts_acknowledged

      [hosts_up, hosts_down, hosts_pending, hosts_unreachable, hosts_in_downtime, hosts_acknowledged]
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

  end
end
