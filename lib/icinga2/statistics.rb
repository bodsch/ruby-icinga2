# frozen_string_literal: true
#

module Icinga2

  # namespace for icinga2 statistics
  module Statistics


    # return statistic data for latency and execution_time
    #
    # @example
    #    @icinga.cib_data
    #    latency, execution_time = @icinga.average_statistics.values
    #
    #    h = @icinga.average_statistics
    #    latency = h.dig(:latency)
    #
    # @return [Hash]
    #    * latency (Float)
    #    * execution_time (Float)
    #
    def average_statistics
      avg_latency        = @avg_latency.nil?        ? 0 : @avg_latency
      avg_execution_time = @avg_execution_time.nil? ? 0 : @avg_execution_time

      {
        latency: avg_latency.to_f,
        execution_time: avg_execution_time.to_f
      }
    end

    # return statistic data for intervall data
    #
    # @example
    #    @icinga.cib_data
    #    hosts_active_checks, hosts_passive_checks, services_active_checks, services_passive_checks = @icinga.interval_statistics.values
    #
    #    i = @icinga.interval_statistics
    #    hosts_active_checks = i.dig(:hosts_active_checks)
    #
    # @return [Hash]
    #    * hosts_active_checks (Float)
    #    * hosts_passive_checks (Float)
    #    * services_active_checks (Float)
    #    * services_passive_checks (Float)
    #
    def interval_statistics

      # take a look into https://github.com/Icinga/pkg-icinga2-debian/blob/master/lib/icinga/cib.cpp

      hosts_active_checks     = @hosts_active_checks_1min.nil?     ? 0 : @hosts_active_checks_1min
      hosts_passive_checks    = @hosts_passive_checks_1min.nil?    ? 0 : @hosts_passive_checks_1min
      services_active_checks  = @services_active_checks_1min.nil?  ? 0 : @services_active_checks_1min
      services_passive_checks = @services_passive_checks_1min.nil? ? 0 : @services_passive_checks_1min

      {
        hosts_active_checks: hosts_active_checks.to_f,
        hosts_passive_checks: hosts_passive_checks.to_f,
        services_active_checks: services_active_checks.to_f,
        services_passive_checks: services_passive_checks.to_f
      }
    end

    # return statistic data for services
    #
    # @example
    #    @icinga.cib_data
    #    ok, warning, critical, unknown, pending, in_downtime, ack = @icinga.service_statistics.values
    #
    #    s = @icinga.service_statistics
    #    critical = s.dig(:critical)
    #
    # @return [Hash]
    #    * ok (Integer)
    #    * warning (Integer)
    #    * critical (Integer)
    #    * unknown (Integer)
    #    * pending (Integer)
    #    * in_downtime (Integer)
    #    * acknowledged (Integer)
    #
    def service_statistics

      services_ok           = @services_ok.nil?           ? 0 : @services_ok
      services_warning      = @services_warning.nil?      ? 0 : @services_warning
      services_critical     = @services_critical.nil?     ? 0 : @services_critical
      services_unknown      = @services_unknown.nil?      ? 0 : @services_unknown
      services_pending      = @services_pending.nil?      ? 0 : @services_pending
      services_in_downtime  = @services_in_downtime.nil?  ? 0 : @services_in_downtime
      services_acknowledged = @services_acknowledged.nil? ? 0 : @services_acknowledged

      {
        ok: services_ok.to_i,
        warning: services_warning.to_i,
        critical: services_critical.to_i,
        unknown: services_unknown.to_i,
        pending: services_pending.to_i,
        in_downtime: services_in_downtime.to_i,
        acknowledged: services_acknowledged.to_i
      }
    end

    # return statistic data for hosts
    #
    # @example
    #    @icinga.cib_data
    #    up, down, pending, unreachable, in_downtime, ack = @icinga.host_statistics.values
    #
    #    h = @icinga.host_statistics
    #    pending = h.dig(:pending)
    #
    # @return [Hash]
    #    * up (Integer)
    #    * down (Integer)
    #    * pending (Integer)
    #    * unreachable (Integer)
    #    * in_downtime (Integer)
    #    * acknowledged (Integer)
    #
    def host_statistics

      hosts_up           = @hosts_up.nil?           ? 0 : @hosts_up
      hosts_down         = @hosts_down.nil?         ? 0 : @hosts_down
      hosts_pending      = @hosts_pending.nil?      ? 0 : @hosts_pending
      hosts_unreachable  = @hosts_unreachable.nil?  ? 0 : @hosts_unreachable
      hosts_in_downtime  = @hosts_in_downtime.nil?  ? 0 : @hosts_in_downtime
      hosts_acknowledged = @hosts_acknowledged.nil? ? 0 : @hosts_acknowledged

      {
        up: hosts_up.to_i,
        down: hosts_down.to_i,
        pending: hosts_pending.to_i,
        unreachable: hosts_unreachable.to_i,
        in_downtime: hosts_in_downtime.to_i,
        acknowledged: hosts_acknowledged.to_i
      }
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
      data   = api_data(
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

        json_rpc_data  = json_rpc_data.dig('status', 'api', 'json_rpc') unless( json_rpc_data.nil? )
        graphite_data  = graphite_data.dig('status', 'graphitewriter', 'graphite')       unless( graphite_data.nil? )
        ido_mysql_data = ido_mysql_data.dig('status', 'idomysqlconnection', 'ido-mysql') unless( ido_mysql_data.nil? )

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
