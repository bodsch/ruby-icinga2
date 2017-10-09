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

    puts ' ==> SERVICES'
    puts ''
    i.service_objects
    puts format( '= count of all services: %s', i.services_all )
    puts ''

    warning, critical, unknown = i.services_adjusted.values

    puts '= daza with adjusted service problems'
    puts format( '  services critical: %d', critical)
    puts format( '  services warning: %d', warning)
    puts format( '  services unknown: %d', unknown)
    puts ''

    ['c1-mysql-1', 'bp-foo'].each do |h|
      e = i.exists_service?( host: h, service: 'ssh' ) ? 'true' : 'false'
      puts format( '= check if Service \'ssh\' for Host \'%s\' exists : %s', h, e )
    end
    puts ''
    ['c1-mysql-1', 'bp-foo'].each do |h|
      e = i.exists_service?( host: h, service: 'hdb' ) ? 'true' : 'false'
      puts format( '= check if Service \'hdb\' for Host \'%s\' exists : %s', h, e )
    end
    puts ''

    puts '= count of all services with \'attr\' and \'joins\' as parameter'
    puts i.service_objects( attrs: %w[name state], joins: ['host.name','host.state'] )
    puts ''

    puts '= count of services with problems'
    puts i.count_services_with_problems
    puts ''

    puts '= 5 Services with Problem '

    problems, problems_and_severity = i.list_services_with_problems.values

    puts format( '  problems: %s', problems )
    puts format( '  problems and severity: %s', problems_and_severity )
    puts ''

    puts '= data with handled (acknowledged or downtimed) service problems'

    all, critical, warning, unknown = i.service_problems_handled.values
    puts format( '  services with problems (all)     : %d', all )
    puts format( '  services with problems (warning) : %d', warning )
    puts format( '  services with problems (critical): %d', critical )
    puts format( '  services with problems (unknown) : %d', unknown )
    puts ''

    puts '= get service Objects'
    puts i.service_objects
    puts ''

    puts '= add service'
    services = {
      'service-heap-mem' => {
        'display_name'  => 'Tomcat - Heap Memory',
        'check_command' => 'tomcat-heap-memory',
      }
    }

    @icinga.add_services( 'foo-bar.lan', services )

    puts i.add_service(
      host: 'c1-mysql-1',
      service_name: 'http2',
      vars: {
        attrs: {
          check_command: 'http',
          check_interval: 10,
          retry_interval: 30,
          vars: {
            http_address: '127.0.0.1',
            http_url: '/access/index',
            http_port: 80
          }
        }
      }
    )


    puts i.modify_service(
      service_name: 'http2',
      vars: {
        attrs: {
          check_interval: 60,
          retry_interval: 10,
          vars: {
            http_url: '/access/login'     ,
            http_address: '10.41.80.63'
          }
        }
      }
    )


#     puts '= Problem Services'
#     a,b = i.list_services_with_problems
#     puts a
#     puts b
#     puts ''
#     puts i.list_services_with_problems(10)
#     puts ''
#     puts '= list named Service \'ping4\' from Host \'icinga2\''
#     puts i.services( host: 'icinga2', service: 'ping4' )
#     puts ''
#     puts '= list all Services'
#     puts i.services

    puts ' ------------------------------------------------------------- '
    puts ''

    rescue => e
      $stderr.puts( e )
      $stderr.puts( e.backtrace.join("\n") )
    end
end


# -----------------------------------------------------------------------------

# EOF
