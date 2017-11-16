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

    puts '= check if Hostgroup \'linux-servers\' exists'
    puts i.exists_hostgroup?( 'linux-servers' ) ? 'true' : 'false'
    puts ''
    puts '= check if Hostgroup \'docker\' exists'
    puts i.exists_hostgroup?( 'docker' ) ? 'true' : 'false'
    puts ''
    puts '= list named Hostgroup \'linux-servers\''
    puts i.hostgroups( host_group: 'linux-servers' )
    puts ''
    puts '= list named Hostgroup \'foo\''
    puts i.hostgroups( host_group: 'foo' )
    puts ''
    puts '= list all Hostgroups'
    puts i.hostgroups
    puts ''
    puts '= add hostgroup \'foo\''
    puts i.add_hostgroup( host_group: 'foo', display_name: 'FOO' )
    puts ''
    puts '= delete Hostgroup \'foo\''
    puts i.delete_hostgroup( host_group: 'foo' )

    puts ' ------------------------------------------------------------- '
    puts ''

    rescue => e
      $stderr.puts( e )
      $stderr.puts( e.backtrace.join("\n") )
    end
end


# -----------------------------------------------------------------------------

# EOF
