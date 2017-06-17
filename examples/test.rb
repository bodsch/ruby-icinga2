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

icinga_host         = ENV.fetch( 'ICINGA_HOST'             , 'icinga2' )
icinga_api_port     = ENV.fetch( 'ICINGA_API_PORT'         , 5665 )
icinga_api_user     = ENV.fetch( 'ICINGA_API_USER'         , 'admin' )
icinga_api_pass     = ENV.fetch( 'ICINGA_API_PASSWORD'     , nil )
icinga_cluster      = ENV.fetch( 'ICINGA_CLUSTER'          , false )
icinga_satellite    = ENV.fetch( 'ICINGA_CLUSTER_SATELLITE', nil )

# convert string to bool
icinga_cluster   = icinga_cluster.to_s.eql?('true') ? true : false

config = {
  icinga: {
    host: icinga_host,
    api: {
      port: icinga_api_port,
      user: icinga_api_user,
      password: icinga_api_pass
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

puts 'Information about Icinga2'
puts i.application_data
puts ''
puts 'CIB'
puts i.cib_data
puts ''
puts 'API Listener'
puts i.api_listener
puts ''

puts format( 'version: %s', i.version )
puts format( 'start time: %s', i.start_time )
puts format( 'uptime: %s', i.uptime )

# puts format( 'host handled warning problems %d', i.hosts_handled_warning_problems)
# puts format( 'host handled critical problems %d', i.hosts_handled_critical_problems)
# puts format( 'host handled unknown problems %d', i.hosts_handled_unknown_problems)
puts format( 'host down %d', i.hosts_down )

puts format( 'service warning %d', i.services_warning)
# puts format( 'service handled warning problems %d', i.services_handled_warning_problems)
puts format( 'service critical %d', i.services_critical)
# puts format( 'service handled critical problems %d', i.services_handled_critical_problems)
puts format( 'service count %d', i.services_unknown)
# puts format( 'service handled unknown problems %d', i.services_handled_unknown_problems)

  # calculate host problems adjusted by handled problems
  # count togther handled host problems
#   hosts_handled_problems     = icinga.hosts_handled_warning_problems + icinga.hosts_handled_critical_problems + icinga.hosts_handled_unknown_problems
#   hosts_down_adjusted        = icinga.hosts_down - hosts_handled_problems
#   # calculate service problems adjusted by handled problems
#   services_warning_adjusted  = icinga.services_warning - icinga.services_handled_warning_problems
#   services_critical_adjusted = icinga.services_critical - icinga.services_handled_critical_problems
#   services_unknown_adjusted  = icinga.services_unknown - icinga.services_handled_unknown_problems


#
# puts 'check if Host \'icinga2\' exists'
# puts i.exists_host?( 'icinga2' ) ? 'true' : 'false'
# puts ''
# puts 'get host Objects'
# puts i.hosts_objects
# puts ''
# puts 'Host problems'
# puts i.hosts_problems
# puts ''
# puts 'Problem Hosts'
# puts i.problem_hosts
# puts ''
# puts 'list named Hosts'
# puts i.hosts( host: 'icinga2' )
# puts i.hosts( host: 'bp-cluster')
# puts ''
# puts 'list all Hosts'
# puts i.hosts
# puts ''
#
# puts 'check if Hostgroup \'linux-servers\' exists'
# puts i.exists_hostgroup?( 'linux-servers' ) ? 'true' : 'false'
# puts ''
# puts 'add hostgroup \'foo\''
# puts i.add_hostgroup( hosts_group: 'foo', display_name: 'FOO' )
# puts ''
# puts 'list named Hostgroup \'foo\''
# puts i.hostgroups( hosts_group: 'foo' )
# puts ''
# puts 'list all Hostgroups'
# puts i.hostgroups
# puts ''
# puts 'delete Hostgroup \'foo\''
# puts i.delete_hostgroup( hosts_group: 'foo' )
# puts ''
#
# puts 'check if service \'users\' on host \'icinga2\' exists'
# puts i.exists_service?( host: 'icinga2', service: 'users' )  ? 'true' : 'false'
# puts ''
# puts 'get service Objects'
# puts i.services_objects
# puts ''
# puts 'Service problems'
# puts i.services_problems
# puts ''
# puts 'Problem Services'
# puts i.problem_services
# puts ''
# puts i.problem_services(10)
# puts ''
# puts 'list named Service \'ping4\' from Host \'icinga2\''
# puts i.services( host: 'icinga2', service: 'ping4' )
# puts ''
# puts 'list all Services'
# puts i.services
# puts ''
#
# puts 'check if Servicegroup \'disk\' exists'
# puts i.exists_servicegroup?( 'disk' ) ? 'true' : 'false'
# puts ''
# puts 'add Servicegroup \'foo\''
# puts i.add_servicegroup( name: 'foo', display_name: 'FOO' )
# puts ''
# puts 'list named Servicegroup \'foo\''
# puts i.servicegroups( name: 'foo' )
# puts ''
# puts 'list all Servicegroup'
# puts i.servicegroups
# puts ''
# puts 'delete Servicegroup \'foo\''
# puts i.delete_servicegroup( name: 'foo' )
# puts ''
#
# puts 'check if Usergroup \'icingaadmins\' exists'
# puts i.exists_usergroup?( 'icingaadmins' ) ? 'true' : 'false'
# puts ''
# puts 'add Usergroup \'foo\''
# puts i.add_usergroup( name: 'foo', display_name: 'FOO' )
# puts ''
# puts 'list named Usergroup \'foo\''
# puts i.usergroups( name: 'foo' )
# puts ''
# puts 'list all Usergroup'
# puts i.usergroups
# puts ''
# puts 'delete Usergroup \'foo\''
# puts i.delete_usergroup( name: 'foo' )
# puts ''
#
# puts 'check if User \'icingaadmin\' exists'
# puts i.exists_user?( 'icingaadmin' ) ? 'true' : 'false'
# puts ''
# puts 'add User \'foo\''
# puts i.add_user( name: 'foo', display_name: 'FOO', email: 'foo@bar.com', pager: '0000', groups: ['icingaadmins'] )
# puts ''
# puts 'list named User \'icingaadmin\''
# puts i.users name: 'icingaadmin'
# puts ''
# puts 'list all User'
# puts i.users
# puts ''
# puts 'delete User \'foo\''
# puts i.delete_user( name: 'foo' )
# puts ''
#
# puts 'add Downtime \'test\''
# puts i.add_downtime( name: 'test', type: 'service', host: 'icinga2', comment: 'test downtime', author: 'icingaadmin', start_time: Time.now.to_i, end_time: Time.now.to_i + 20 )
# puts ''
# puts 'list all Downtimes'
# puts i.downtimes
# puts ''
# puts 'list all Notifications'
# puts i.notifications
# puts ''
# puts 'enable Notifications for host'
# puts i.enable_hosts_notification( 'icinga2' )
# puts ''
# puts 'disable Notifications for host'
# puts i.disable_hosts_notification( 'icinga2' )
# puts ''
# puts 'enable Notifications for host and services'
# puts i.enable_services_notification('icinga2')
# puts ''
# puts 'disable Notifications for host and services'
# puts i.disable_services_notification( 'icinga2' )
# puts ''
# puts 'enable Notifications for hostgroup'
# puts i.enable_hostgroup_notification( host: 'icinga2', hosts_group: 'linux-servers')
# puts ''
# puts 'disable Notifications for hostgroup'
# puts i.disable_hostgroup_notification( host: 'icinga2', hosts_group: 'linux-servers')
# puts ''

end

# -----------------------------------------------------------------------------

# EOF
