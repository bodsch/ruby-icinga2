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

config = {
  icinga: {
    host: icinga_host,
    api: {
      port: icinga_api_port,
      user: icinga_api_user,
      password: icinga_api_pass,
      pki_path: icinga_api_pki_path,
      node_name: icinga_api_node_name
    }
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

    v, r = i.version.values
    l, e = i.average_statistics.values
    puts format( '= version: %s, revision %s', v, r )
    puts format( '= avg_latency: %s, avg_execution_time %s', l, e )
    puts format( '= start time: %s', i.start_time )
    puts format( '= uptime: %s', i.uptime )
    puts format( '= node name: %s', i.node_name )
    puts ''

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

    puts ' ------------------------------------------------------------- '
    puts ''

    rescue => e
      $stderr.puts( e )
      $stderr.puts( e.backtrace.join("\n") )
    end
end


# -----------------------------------------------------------------------------

# EOF
