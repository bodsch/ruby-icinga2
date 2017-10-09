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

    puts '= service objects'
    puts i.service_objects
    puts ''

    puts '= service objects with \'attrs\' and \'joins\''
    puts i.service_objects( attrs: ['name', 'state'], joins: ['host.name','host.state'] )
    puts ''

    puts '= unhandled services'
    puts i.unhandled_services
    puts ''

    puts format( '= count of all services: %s', i.services_all )
    puts ''

    puts format( '= count of services with problems: %d', i.count_services_with_problems)
    puts ''

    all, warning, critical, unknown, pending, in_downtime, acknowledged,
        adjusted_warning, adjusted_critical, adjusted_unknown,
        handled_all, handled_warning, handled_critical, handled_unknown = i.service_problems.values

    puts '= services with problems'
    puts i.service_problems
    puts format( '  - all             : %d', all )
    puts format( '  - warning         : %d', warning )
    puts format( '  - critical        : %d', critical )
    puts format( '  - unknown         : %d', unknown )
    puts format( '  - pending         : %d', pending )
    puts format( '  - in_downtime     : %d', in_downtime )
    puts format( '  - acknowledged    : %d', acknowledged )
    puts format( '  - adj. warning    : %d', adjusted_warning )
    puts format( '  - adj. critical   : %d', adjusted_critical )
    puts format( '  - adj. unknown    : %d', adjusted_unknown )
    puts format( '  - handled all     : %d', handled_all )
    puts format( '  - handled warning : %d', handled_warning )
    puts format( '  - handled critical: %d', handled_critical )
    puts format( '  - handled unknown : %d', handled_unknown )
    puts ''

    puts '= check if Service exists'
    ['c1-mysql-1', 'bp-foo'].each do |h|
      e = i.exists_service?( host: h, service: 'ssh' ) ? 'true' : 'false'
      puts format( '  - Service \'ssh\' for Host \'%s\' : %s', h, e )
    end
    puts ''
    ['c1-mysql-1', 'bp-foo'].each do |h|
      e = i.exists_service?( host: h, service: 'hdb' ) ? 'true' : 'false'
      puts format( '  - Service \'hdb\' for Host \'%s\' : %s', h, e )
    end
    puts ''

    puts '= 5 Services with Problems'

    problems, problems_and_severity = i.list_services_with_problems.values

    puts format( '  - problems: %s', problems )
    puts format( '  - problems and severity: %s', problems_and_severity )
    puts ''


    puts '= get service Objects'
    puts i.service_objects
    puts ''

    puts '= add service'
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

    puts '= add service (again)'
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

    puts '= modify service'
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

    puts '= delete service'
    puts i.delete_service(host: 'c1-mysql-1', service_name: 'http2' )

    puts '= delete service (again)'
    puts i.delete_service(host: 'c1-mysql-1', service_name: 'http2' )

    puts ''
    puts '= list named Service \'ping4\' from Host \'icinga2\''
    puts i.services( host: 'c1-mysql-1', service: 'ping4' )
    puts ''
    puts '= list all Services'
    puts i.services

    puts ' ------------------------------------------------------------- '
    puts ''

  rescue => e
    $stderr.puts( e )
    $stderr.puts( e.backtrace.join("\n") )
  end
end


# -----------------------------------------------------------------------------

# EOF
