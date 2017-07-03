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
icinga_api_pki_path  = ENV.fetch( 'ICINGA_API_PKI_PATH'     , '/home/bodsch/icinga2' )
icinga_api_node_name = ENV.fetch( 'ICINGA_API_NODE_NAME'    , 'dunkelzahn' )
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

#   puts 'Information about Icinga2'
#   puts i.application_data
#  puts ''
#  puts 'CIB'
#  puts i.cib_data
#  puts ''
#  puts 'API Listener'
#  puts i.api_listener
#
#  puts ''
#  puts format( 'version: %s, revision %s', i.version, i.revision )
#  puts format( 'start time: %s', i.start_time )
#  puts format( 'uptime: %s', i.uptime )
#
#  puts ''
#  puts format( 'count of all hosts: %d', i.hosts_all )
#  puts format( 'host down: %d', i.hosts_down )
#  puts format( 'hosts problems down: %d', i.hosts_problems_down )
#
#  puts ''
#  puts format( 'count of all services: %d', i.services_all )
#  puts format( 'services critical: %d', i.services_critical)
#  puts format( 'services warning: %d', i.services_warning)
#  puts format( 'services unknown: %d', i.services_unknown)
#  puts ''
#  puts format( 'services handled warning problems: %d', i.services_handled_warning_problems)
#  puts format( 'services handled critical problems: %d', i.services_handled_critical_problems)
#  puts format( 'services handled unknown problems: %d', i.services_handled_unknown_problems)
#  puts ''
#  puts format( 'services adjusted critical: %d', i.services_critical_adjusted)
#  puts format( 'services adjusted warning: %d',  i.services_warning_adjusted)
#  puts format( 'services adjusted unknown: %d',  i.services_unknown_adjusted)
#  puts ''
#
#  puts 'check if Host \'icinga2\' exists'
#  puts i.exists_host?( 'icinga2' ) ? 'true' : 'false'
#  puts ''
#  puts 'get host Objects'
#  puts i.host_objects
#  puts ''
#  puts 'Host problems'
#  puts i.host_problems
#  puts ''
#  puts 'Problem Hosts'
#  puts i.problem_hosts
#  puts ''
#  puts 'list named Hosts'
#  puts i.hosts( host: 'icinga2' )
#  puts i.hosts( host: 'bp-cluster')
#  puts ''
#  puts 'list all Hosts'
#  puts i.hosts
#  puts ''
#
#  puts 'check if Hostgroup \'linux-servers\' exists'
#  puts i.exists_hostgroup?( 'linux-servers' ) ? 'true' : 'false'
#  puts ''
#  puts 'add hostgroup \'foo\''
#  puts i.add_hostgroup( hosts_group: 'foo', display_name: 'FOO' )
#  puts ''
#  puts 'list named Hostgroup \'foo\''
#  puts i.hostgroups( hosts_group: 'foo' )
#  puts ''
#  puts 'list all Hostgroups'
#  puts i.hostgroups
#  puts ''
#  puts 'delete Hostgroup \'foo\''
#  puts i.delete_hostgroup( hosts_group: 'foo' )
#  puts ''
#
#  puts 'check if service \'users\' on host \'icinga2\' exists'
#  puts i.exists_service?( host: 'icinga2', service: 'users' )  ? 'true' : 'false'
#  puts ''
#  puts 'get service Objects'
#  puts i.service_objects
#  puts ''
#  puts 'Service problems'
#  puts i.service_problems
#  puts ''
#  puts 'Problem Services'
#  a,_b = i.problem_services
#  puts a
#  puts ''
#  puts i.problem_services(10)
#  puts ''
#  puts 'list named Service \'ping4\' from Host \'icinga2\''
#  puts i.services( host: 'icinga2', service: 'ping4' )
#  puts ''
#  puts 'list all Services'
#  puts i.services
#  puts ''
#
#  puts 'check if Servicegroup \'disk\' exists'
#  puts i.exists_servicegroup?( 'disk' ) ? 'true' : 'false'
#  puts ''
#  puts 'add Servicegroup \'foo\''
#  puts i.add_servicegroup( name: 'foo', display_name: 'FOO' )
#  puts ''
#  puts 'list named Servicegroup \'foo\''
#  puts i.servicegroups( name: 'foo' )
#  puts ''
#  puts 'list all Servicegroup'
#  puts i.servicegroups
#  puts ''
#  puts 'delete Servicegroup \'foo\''
#  puts i.delete_servicegroup( name: 'foo' )
#  puts ''
#
#  puts 'check if Usergroup \'icingaadmins\' exists'
#  puts i.exists_usergroup?( 'icingaadmins' ) ? 'true' : 'false'
#  puts ''
#  puts 'add Usergroup \'foo\''
#  puts i.add_usergroup( name: 'foo', display_name: 'FOO' )
#  puts ''
#  puts 'list named Usergroup \'foo\''
#  puts i.usergroups( name: 'foo' )
#  puts ''
#  puts 'list all Usergroup'
#  puts i.usergroups
#  puts ''
#  puts 'delete Usergroup \'foo\''
#  puts i.delete_usergroup( name: 'foo' )
#  puts ''
#
#  puts 'check if User \'icingaadmin\' exists'
#  puts i.exists_user?( 'icingaadmin' ) ? 'true' : 'false'
#  puts ''
#  puts 'add User \'foo\''
#  puts i.add_user( name: 'foo', display_name: 'FOO', email: 'foo@bar.com', pager: '0000', groups: ['icingaadmins'] )
#  puts ''
#  puts 'list named User \'icingaadmin\''
#  puts i.users name: 'icingaadmin'
#  puts ''
#  puts 'list all User'
#  puts i.users
#  puts ''
#  puts 'delete User \'foo\''
#  puts i.delete_user( name: 'foo' )
#  puts ''
#
#  puts 'add Downtime \'test\''
#  puts i.add_downtime( name: 'test', type: 'service', host: 'icinga2', comment: 'test downtime', author: 'icingaadmin', start_time: Time.now.to_i, end_time: Time.now.to_i + 20 )
#  puts ''
#  puts 'list all Downtimes'
#  puts i.downtimes
#  puts ''
#  puts 'list all Notifications'
#  puts i.notifications
#  puts ''
#  puts 'enable Notifications for host'
#  puts i.enable_host_notification( 'icinga2' )
#  puts ''
#  puts 'disable Notifications for host'
#  puts i.disable_host_notification( 'icinga2' )
#  puts ''
#  puts 'enable Notifications for host and services'
#  puts i.enable_service_notification('icinga2')
#  puts ''
#  puts 'disable Notifications for host and services'
#  puts i.disable_service_notification( 'icinga2' )
#  puts ''
#  puts 'enable Notifications for hostgroup'
#  puts i.enable_hostgroup_notification( host: 'icinga2', host_group: 'linux-servers')
#  puts ''
#  puts 'disable Notifications for hostgroup'
#  puts i.disable_hostgroup_notification( host: 'icinga2', host_group: 'linux-servers')
#  puts ''
#
#  puts 'work queue statistics'
#  puts i.work_queue_statistics

end

# -----------------------------------------------------------------------------

# EOF
