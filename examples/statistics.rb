#!/usr/bin/env ruby
# frozen_string_literal: true
#
# 07.10.2017 - Bodo Schulz
#
#
# Examples for Hostgroups

# -----------------------------------------------------------------------------

require_relative '../lib/icinga2'

# -----------------------------------------------------------------------------

icinga_host          = ENV.fetch( 'ICINGA_HOST'             , 'icinga2' )
icinga_api_port      = ENV.fetch( 'ICINGA_API_PORT'         , 5665 )
icinga_api_user      = ENV.fetch( 'ICINGA_API_USER'         , 'admin' )
icinga_api_pass      = ENV.fetch( 'ICINGA_API_PASSWORD'     , nil )
icinga_api_pki_path  = ENV.fetch( 'ICINGA_API_PKI_PATH'     , '/etc/icinga2' )
icinga_api_node_name = ENV.fetch( 'ICINGA_API_NODE_NAME'    , nil )
icinga_cluster       = ENV.fetch( 'ICINGA_CLUSTER'          , false )
icinga_satellite     = ENV.fetch( 'ICINGA_CLUSTER_SATELLITE', nil )


# convert string to bool
icinga_cluster   = icinga_cluster.to_s.eql?('true') ? true : false

config = {
  icinga: {
    host: icinga_host,
    api: {
      port: icinga_api_port,
      user: icinga_api_user,
      password: icinga_api_pass,
      pki_path: icinga_api_pki_path,
      node_name: icinga_api_node_name
    },
    cluster: icinga_cluster,
    satellite: icinga_satellite
  }
}

# ---------------------------------------------------------------------------------------

i = Icinga2::Client.new( config )

unless( i.nil? )

  # run tests ...
  #
  #

  begin

    i.cib_data

    puts ' ------------------------------------------------------------- '
    puts ''

    latency, execution_time = i.average_statistics.values

    puts format( '= latency: %s', latency )
    puts format( '= execution_time: %s', execution_time )
    puts ''

    interval_stats   = i.interval_statistics
    host_stats       = i.host_statistics
    service_stats    = i.service_statistics
    work_queue_stats = i.work_queue_statistics

    hosts_active_checks        = interval_stats.dig(:hosts_active_checks)
    hosts_passive_checks       = interval_stats.dig(:hosts_passive_checks)
    services_active_checks     = interval_stats.dig(:services_active_checks)
    services_passive_checks    = interval_stats.dig(:services_passive_checks)

    host_stats_up              = host_stats.dig(:up)
    host_stats_down            = host_stats.dig(:down)
    host_stats_pending         = host_stats.dig(:pending)
    host_stats_unreachable     = host_stats.dig(:unreachable)
    host_stats_in_downtime     = host_stats.dig(:in_downtime)
    host_stats_acknowledged    = host_stats.dig(:acknowledged)

    service_stats_ok           = service_stats.dig(:ok)
    service_stats_warning      = service_stats.dig(:warning)
    service_stats_critical     = service_stats.dig(:critical)
    service_stats_unknown      = service_stats.dig(:unknown)
    service_stats_pending      = service_stats.dig(:pending)
    service_stats_in_downtime  = service_stats.dig(:in_downtime)
    service_stats_acknowledged = service_stats.dig(:acknowledged)

    puts format( '= hosts')
    puts format( '  active checks : %s', hosts_active_checks )
    puts format( '  passive checks: %s', hosts_passive_checks )
    puts ''
    puts format( '= host statistics')
    puts format( '  up            : %s', host_stats_up )
    puts format( '  down          : %s', host_stats_down )
    puts format( '  pending       : %s', host_stats_pending )
    puts format( '  unreachable   : %s', host_stats_unreachable )
    puts format( '  in downtime   : %s', host_stats_in_downtime )
    puts format( '  acknowledged  : %s', host_stats_acknowledged )
    puts ''

    puts format( '= services')
    puts format( '  active checks : %s', services_active_checks )
    puts format( '  passive checks: %s', services_passive_checks )
    puts ''
    puts format( '= service statistics')
    puts format( '  ok            : %s', service_stats_ok )
    puts format( '  warning       : %s', service_stats_warning )
    puts format( '  critical      : %s', service_stats_critical )
    puts format( '  unknown       : %s', service_stats_unknown )
    puts format( '  pending       : %s', service_stats_pending )
    puts format( '  in downtime   : %s', service_stats_in_downtime )
    puts format( '  acknowledged  : %s', service_stats_acknowledged )
    puts ''
    puts format( '= workqueue statistics')

    work_queue_stats.each do |k,v|
      puts format('  %s : %s', k, v )
    end
    puts ''

    puts ' ------------------------------------------------------------- '
    puts ''

    rescue => e
      $stderr.puts( e )
      $stderr.puts( e.backtrace.join("\n") )
    end
end


# -----------------------------------------------------------------------------

# EOF

