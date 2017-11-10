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

  puts ''
  puts ' ============================================================= '
  puts '= icinga2 available'
  puts i.available?
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

  v, r = i.version
  l, e = i.average_statistics
  puts format( '= version: %s, revision %s', v, r )
  puts format( '= avg_latency: %s, avg_execution_time %s', l, e )
  puts format( '= start time: %s', i.start_time )
  puts format( '= uptime: %s', i.uptime )
  puts ''

  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''
  puts ' ==> HOSTS'
  puts ''

  i.cib_data
  i.host_objects

  p, a = i.hosts_adjusted

  puts format( '= host handled problems : %s', p )
  puts format( '= host down adjusted    : %s', a )

  puts '= host objects'

  all, down, critical, unknown = i.host_problems.values

  puts format( '= count of all hosts : %d', i.hosts_all )
  puts format( '= hosts with problems: %s', i.list_hosts_with_problems )
  puts format( '= hosts are down     : %d', down )
  puts format( '= hosts are critical : %d', critical )
  puts format( '= hosts are unknown  : %d', unknown )
  puts format( '= count hosts w. problems: %d', i.count_hosts_with_problems )

  ['icinga2', 'bp-foo'].each do |h|
    puts format( '= check if Host \'%s\' exists', h )
    puts i.exists_host?( h ) ? 'true' : 'false'
  end

  puts ''
  puts '= Problem Hosts'
  puts i.list_hosts_with_problems
  puts ''

  ['icinga2', 'bp-foo'].each do |h|
    puts format('= list named Hosts \'%s\'', h )
    puts i.hosts( host: h )
  end

  puts ''
  puts '= list all Hosts'
  puts i.hosts
  puts ''
  puts ' = delete Host'
  puts i.delete_host( host: 'foo' )
  puts ''
  puts ' = add Host'
  puts i.add_host(
     name: 'foo',
     address: 'foo.bar.com',
     display_name: 'test node',
     max_check_attempts: 5,
     notes: 'test node'
  )
  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''

  puts ' ------------------------------------------------------------- '
  puts ''
  puts ' ==> HOSTGROUPS'
  puts ''
  puts '= check if Hostgroup \'linux-servers\' exists'
  puts i.exists_hostgroup?( 'linux-servers' ) ? 'true' : 'false'
  puts ''
  puts '= list named Hostgroup \'linux-servers\''
  puts i.hostgroups( host_group: 'linux-servers' )
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
  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''

  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''
  puts ' ==> SERVICES'
  puts ''
  i.cib_data
  i.service_objects

  all, warning, critical, unknown, pending, in_downtime, acknowledged = i.service_problems.values
  puts format( '= count of all services: %d', i.services_all )
  puts format( '= services warning: %d', warning)
  puts format( '= services critical: %d', critical)
  puts format( '= services unknown: %d', unknown)
  puts format( '= services in downtime: %d', in_downtime)
  puts format( '= services acknowledged: %d', acknowledged)

  puts ''
  all, warning, critical, unknown = i.service_problems_handled.values
  puts format( '= services handled warning problems: %d', warning)
  puts format( '= services handled critical problems: %d', critical)
  puts format( '= services handled unknown problems: %d', unknown)
  puts ''
  warning, critical, unknown = i.services_adjusted.values
  puts format( '= services adjusted warning: %d',  warning)
  puts format( '= services adjusted critical: %d', critical)
  puts format( '= services adjusted unknown: %d',  unknown)

  puts ''
  puts '= check if service \'users\' on host \'icinga2\' exists'
  puts i.exists_service?( host: 'icinga2', service: 'users' )  ? 'true' : 'false'
  puts ''
  puts '= get service Objects'
  puts i.service_objects
  puts ''
  puts '= Services with problems'
  puts i.count_services_with_problems
  puts ''
  puts '= Problem Services'
  a,b = i.list_services_with_problems
  puts a
  puts b
  puts ''
  puts i.list_services_with_problems(10)
  puts ''
  puts '= list named Service \'ping4\' from Host \'icinga2\''
  puts i.services( host: 'icinga2', service: 'ping4' )
  puts ''
  puts '= list all Services'
  puts i.services
  puts ''
  puts '= add Service'
  puts i.add_services(
    host: 'icinga2',
    service_name: 'new_http',
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
  puts ''
  puts '= list new named Service \'new_http\' from Host \'icinga2\''
  puts i.services( host: 'icinga2', service: 'new_http' )
  puts ''
  puts '= modify named Service \'new_http\' from Host \'icinga2\''
  puts JSON.pretty_generate  i.modify_service(
    service_name: 'new_http',
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
  puts ''
  puts '= list modified named Service \'new_http\' from Host \'icinga2\''
  puts  JSON.pretty_generate i.services( host: 'icinga2', service: 'new_http' )
  puts ''
  puts '= delete named Service \'new_http\' from Host \'icinga2\''
  puts i.delete_service(
    host: 'icinga2',
    service_name: 'new_http',
    cascade: true
  )
  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''

  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''
  puts ' ==> SERVICEGROUPS'
  puts ''
  puts 'check if Servicegroup \'disk\' exists'
  puts i.exists_servicegroup?( 'disk' ) ? 'true' : 'false'
  puts 'check if Servicegroup \'foo\' exists'
  puts i.exists_servicegroup?( 'foo' ) ? 'true' : 'false'
  puts ''
  puts 'list named Servicegroup \'foo\''
  puts i.servicegroups( service_group: 'foo' )
  puts 'list named Servicegroup \'disk\''
  puts i.servicegroups( service_group: 'disk' )
  puts ''
  puts 'list all Servicegroup'
  puts i.servicegroups
  puts ''
  puts 'add Servicegroup \'foo\''
  puts i.add_servicegroup( service_group: 'foo', display_name: 'FOO' )
  puts ''
  puts 'delete Servicegroup \'foo\''
  puts i.delete_servicegroup( service_group: 'foo' )
  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''

  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''
  puts ' ==> USERS'
  puts ''
  puts 'check if User \'icingaadmin\' exists'
  puts i.exists_user?( 'icingaadmin' ) ? 'true' : 'false'
  puts ''
  puts 'list named User \'icingaadmin\''
  puts i.users( user_name: 'icingaadmin' )
  puts ''
  puts 'list all User'
  puts i.users
  puts ''
  puts 'add User \'foo\''
  puts i.add_user( user_name: 'foo', display_name: 'FOO', email: 'foo@bar.com', pager: '0000', groups: ['icingaadmins'] )
  puts ''
  puts 'delete User \'foo\''
  puts i.delete_user( user_name: 'foo' )
  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''
  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''
  puts ' ==> USERGROUPS'
  puts ''
  puts 'check if Usergroup \'icingaadmins\' exists'
  puts i.exists_usergroup?( 'icingaadmins' ) ? 'true' : 'false'
  puts ''
  puts 'list named Usergroup \'icingaadmins\''
  puts i.usergroups( user_group: 'icingaadmins' )
  puts ''
  puts 'list all Usergroup'
  puts i.usergroups
  puts ''
  puts 'add Usergroup \'foo\''
  puts i.add_usergroup( user_group: 'foo', display_name: 'FOO' )
  puts ''
  puts 'delete Usergroup \'foo\''
  puts i.delete_usergroup( user_group: 'foo' )
  puts ''
  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''

  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''
  puts ' ==> DOWNTIMES'
  puts ''
  puts 'add Downtime \'test\''
  puts i.add_downtime( name: 'test', type: 'service', host: 'foo', comment: 'test downtime', author: 'icingaadmin', start_time: Time.now.to_i, end_time: Time.now.to_i + 20 )
  puts ''
  puts 'list all Downtimes'
  puts i.downtimes
  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''

  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''
  puts ' ==> NOTIFICATIONS'
  puts ''
  puts 'list all Notifications'
  puts i.notifications
  puts ''
  puts 'enable Notifications for host'
  puts i.enable_host_notification( 'icinga2' )
  puts ''
  puts 'disable Notifications for host'
  puts i.disable_host_notification( 'icinga2' )
  puts ''
  puts 'enable Notifications for host and services'
  puts i.enable_service_notification('icinga2')
  puts ''
  puts 'disable Notifications for host and services'
  puts i.disable_service_notification( 'icinga2' )
  puts ''
  puts 'enable Notifications for hostgroup'
  puts i.enable_hostgroup_notification( host: 'icinga2', host_group: 'linux-servers')
  puts ''
  puts 'disable Notifications for hostgroup'
  puts i.disable_hostgroup_notification( host: 'icinga2', host_group: 'linux-servers')
  puts ''
  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''

  puts ''
  puts ' ------------------------------------------------------------- '
  puts ''
  puts ' ==> WORK QUEUE STATISTICS'
  puts ''
  puts 'work queue statistics'
  puts i.work_queue_statistics
  puts ''
  puts ' ------------------------------------------------------------- '
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

end


# -----------------------------------------------------------------------------

# EOF
