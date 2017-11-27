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

    puts format( '= count of all hosts   : %d', i.hosts_all )
    puts format( '= count_hosts_with_problems: %d', i.count_hosts_with_problems)
    puts ''

    all, down, critical, unknown, handled, adjusted = i.host_problems.values

    puts '= hosts with problems'
    puts format( '  - all     : %d', all )
    puts format( '  - down    : %d', down )
    puts format( '  - critical: %d', critical )
    puts format( '  - unknown : %d', unknown )
    puts format( '  - handled : %d', handled )
    puts format( '  - adjusted: %d', adjusted )
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
      puts i.hosts( name: h )
      puts ''
    end

    puts ' = add Host \'foo\''

    options = {
      name: 'foo',
      address: 'foo.bar.com',
      display_name: 'test node',
      max_check_attempts: 5,
      notes: 'test node',
      vars: {
        description: 'spec test',
        os: 'Docker',
        partitions: {
          '/' => {
            crit: '95%',
            warn: '90%'
          }
        }
      }
    }

    puts i.add_host(options)
    puts ''

    puts ' = add Host \'foo\' (again)'
    puts i.add_host(options)
    puts ''

    puts ' = modify Host \'foo\' with merge vars'
    options = {
      name: 'foo',
      display_name: 'test node (changed)',
      max_check_attempts: 10,
      notes: 'spec test',
      vars: {
        description: 'changed at ...'
      },
      merge_vars: true
    }
    puts i.modify_host(options)
    puts ''

    puts ' = modify Host \'foo\' with overwrite vars'
    options = {
      name: 'foo',
      display_name: 'test node (changed)',
      max_check_attempts: 10,
      notes: 'spec test',
      vars: {
        description: 'change and overwrite vars'
      }
    }
    puts i.modify_host(options)
    puts ''

    puts ' = delete Host \'test\''
    puts i.delete_host( name: 'test' )
    puts ''

    puts ' = delete Host \'foo\''
    puts i.delete_host( name: 'foo' )
    puts ''

    puts ' = delete Host \'foo\' (again)'
    puts i.delete_host( name: 'foo' )
    puts ''

    puts '= list all Hosts'
    puts i.hosts
    puts ''

    puts '= list named Hosts \'c1-mysql-1\''
    puts i.hosts(name: 'c1-mysql-1')
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
