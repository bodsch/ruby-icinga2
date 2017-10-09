#!/usr/bin/env ruby
# frozen_string_literal: true
#
# 23.01.2017 - Bodo Schulz
#
#
# v0.9.2

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
    puts ''
    puts ' ============================================================= '
    puts '= icinga2 status'
    puts i.status_data
    puts ''

    puts '= icinga2 application data'
    puts i.application_data
    puts ''
    puts '= CIB'
    puts i.cib_data
    puts ''
    puts '= API Listener'
    puts i.api_listener
    puts ''

    v, r = i.version.values
    l, e = i.average_statistics.values
    puts format( '= version: %s, revision %s', v, r )
    puts format( '= avg_latency: %s, avg_execution_time %s', l, e )
    puts format( '= start time: %s', i.start_time )
    puts format( '= uptime: %s', i.uptime )
    puts ''


#   # examples from: https://github.com/saurabh-hirani/icinga2-api-examples
#   #
#   # Get display_name, check_command attribute for services applied for filtered hosts matching host.address == 1.2.3.4.
#   # Join the output with the hosts on which these checks run (services are applied to hosts)
#   #
#   puts i.service_objects(
#     attrs: ["display_name", "check_command"],
#     filter: "match(\"1.2.3.4\",host.address)" ,
#     joins: ["host.name", "host.address"]
#   )
#
#   puts ''
#
#   # Get all services in critical state and filter out the ones for which active checks are disabled
#   # service.states - 0 = OK, 1 = WARNING, 2 = CRITICAL
#   #
#   # { "joins": ["host.name", "host.address"], "filter": "service.state==2", "attrs": ["display_name", "check_command", "enable_active_checks"] }
#   puts i.service_objects(
#     attrs: ["display_name", "check_command", "enable_active_checks"],
#     filter: "service.state==1" ,
#     joins: ["host.name", "host.address"]
#   )
#
#   puts ''
#   # Get host name, address of hosts belonging to a specific hostgroup
#   puts i.host_objects(
#     attrs: ["display_name", "name", "address"],
#     filter: "\"windows-servers\" in host.groups"
#   )

    rescue => e
      $stderr.puts( e )
      $stderr.puts( e.backtrace.join("\n") )
    end
end


# -----------------------------------------------------------------------------

# EOF
