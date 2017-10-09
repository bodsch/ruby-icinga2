#!/usr/bin/env ruby
# frozen_string_literal: true
#
# 07.10.2017 - Bodo Schulz
#
#
# Examples for Hosts

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
    puts ' ==> HOSTS'
    puts ''

    handled, down = i.hosts_adjusted.values

    puts format( '= host adjusted handled: %d', handled )
    puts format( '= host adjusted down   : %d', down )

    puts ''
    all, down, critical, unknown = i.host_problems.values

    puts format( '= count of all hosts            : %d', i.hosts_all )
    puts format( '= hosts with problems (all)     : %d', all )
    puts format( '= hosts with problems (down)    : %d', down )
    puts format( '= hosts with problems (critical): %d', critical )
    puts format( '= hosts with problems (unknown) : %d', unknown )
    puts ''

    puts ''
    ['c1-mysql-1', 'bp-foo'].each do |h|

      e = i.exists_host?( h ) ? 'true' : 'false'
      puts format( '= check if Host \'%s\' exists : %s', h, e )
    end

    puts ''

    puts '= 5 Hosts with Problem '
    puts i.list_hosts_with_problems
    puts ''

    ['c1-mysql-1', 'bp-foo'].each do |h|
      puts format('= list named Hosts \'%s\'', h )
      puts i.hosts( host: h )
      puts ''
    end

    puts ' = add Host \'foo\''
    puts i.add_host(
       host: 'foo',
       fqdn: 'foo.bar.com',
       display_name: 'test node',
       max_check_attempts: 5,
       notes: 'test node'
    )
    puts ''

    puts ' = add Host \'foo\''
    puts i.add_host(
       host: 'foo',
       fqdn: 'foo.bar.com',
       display_name: 'test node',
       max_check_attempts: 5,
       notes: 'test node'
    )
    puts ''

    puts ' = delete Host \'foo\''
    puts i.delete_host( host: 'foo' )
    puts ''

    puts ' = delete Host \'foo\''
    puts i.delete_host( host: 'foo' )
    puts ''

    puts '= list all Hosts'
    puts i.hosts
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
