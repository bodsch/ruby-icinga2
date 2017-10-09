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

    puts ' ------------------------------------------------------------- '
    puts ''

    puts ' ==> NOTIFICATIONS'
    puts ''
    puts '= list all Notifications'
    puts i.notifications
    puts ''

    ['c1-mysql-1', 'bp-foo'].each do |h|
      puts format( '= enable Notifications for \'%s\'', h )
      puts i.enable_host_notification( h )
    end
    puts ''

    ['c1-mysql-1', 'bp-foo'].each do |h|
      puts format( '= disable Notifications for \'%s\'', h )
      puts i.disable_host_notification( h )
    end
    puts ''

    ['c1-mysql-1', 'bp-foo'].each do |h|
      puts format( '= enable Notifications for \'%s\' and they services', h )
      puts i.enable_service_notification( h )
    end
    puts ''

    ['c1-mysql-1', 'bp-foo'].each do |h|
      puts format( '= disable Notifications for \'%s\' and they services', h )
      puts i.disable_service_notification( h )
    end
    puts ''

    puts '= enable Notifications for hostgroup'
    puts i.enable_hostgroup_notification( host_group: 'linux-servers')
    puts ''


    puts '= disable Notifications for hostgroup'
    puts i.disable_hostgroup_notification( host_group: 'linux-servers')
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
