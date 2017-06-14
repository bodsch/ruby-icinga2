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

#  # run tests ...
#  #
#  #
#
puts 'Information about Icinga2:'
puts i.application_data
#  puts i.cib_data()
#  puts i.api_listener
#  puts ''
#
#  puts "check if Host 'icinga2-master' exists:"
#  puts i.exists_host?( 'icinga2-master' ) ? 'true' : 'false'
#  puts "get host Objects from 'icinga2-master'"
#  puts i.host_objects
#  puts 'Host problems:'
#  puts i.host_problems
#  puts 'Problem Hosts:'
#  puts i.problem_hosts
#
#  puts 'list named Hosts:'
#  puts i.hosts( name: 'icinga2-master' )
#  puts 'list all Hosts:'
#  puts i.hosts
#  puts ''
#
#  puts "check if Hostgroup 'linux-servers' exists:"
#  puts i.exists_hostgroup?( 'linux-servers' ) ? 'true' : 'false'
#  puts "add hostgroup 'foo'"
#  puts i.add_hostgroup( name: 'foo', display_name: 'FOO' )
#  puts "list named Hostgroup 'foo'"
#  puts i.hostgroups( name: 'foo' )
#  puts 'list all Hostgroups:'
#  puts i.hostgroups
#  puts "delete Hostgroup 'foo'"
#  puts i.delete_hostgroup( name: 'foo' )
#  puts ''
#
#  puts "check if service 'users' on host 'icinga2-master' exists:"
#  puts i.exists_service?( host: 'icinga2-master', service: 'users' )  ? 'true' : 'false'
#
#  puts 'get service Objects'
#  puts i.service_objects
#  puts 'Service problems:'
#  puts i.service_problems
#  puts 'Problem Services:'
#  puts i.problem_services
#
#  puts "list named Service 'ping4' from Host 'icinga2-master'"
#  puts i.services( host: 'icinga2-master', service: 'ping4' )
#  puts 'list all Services:'
#  puts i.services
#  puts ''
#
#  puts "check if Servicegroup 'disk' exists:"
#  puts i.exists_servicegroup?( 'disk' ) ? 'true' : 'false'
#  puts "add Servicegroup 'foo'"
#  puts i.add_servicegroup( name: 'foo', display_name: 'FOO' )
#  puts "list named Servicegroup 'foo'"
#  puts i.servicegroups( name: 'foo' )
#  puts 'list all Servicegroup:'
#  puts i.servicegroups
#  puts "delete Servicegroup 'foo'"
#  puts i.delete_servicegroup( name: 'foo' )
#  puts ''
#
#  puts "check if Usergroup 'icingaadmins' exists:"
#  puts i.exists_usergroup?( 'icingaadmins' ) ? 'true' : 'false'
#  puts "add Usergroup 'foo'"
#  puts i.add_usergroup( name: 'foo', display_name: 'FOO' )
#  puts "list named Usergroup 'foo'"
#  puts i.usergroups( name: 'foo' )
#  puts 'list all Usergroup:'
#  puts i.usergroups
#  puts "delete Usergroup 'foo'"
#  puts i.delete_usergroup( name: 'foo' )
#  puts ''
#
#  puts "check if User 'icingaadmin' exists:"
#  puts i.exists_user?( 'icingaadmin' ) ? 'true' : 'false'
#  puts "add User 'foo'"
#  puts i.add_user( name: 'foo', display_name: 'FOO', email: 'foo@bar.com', pager: '0000', groups: ['icingaadmins'] )
#  puts "list named User 'foo'"
#  puts i.users( name: 'foo' )
#  puts 'list all User:'
#  puts i.users
#  puts "delete User 'foo'"
#  puts i.delete_user( name: 'foo' )
#  puts ''

  puts "add Downtime 'test':"
  puts i.add_downtime( name: 'test', type: 'service', host: 'icinga2', comment: 'test downtime', author: 'icingaadmin', start_time: Time.now.to_i, end_time: Time.now.to_i + 20 )
  puts 'list all Downtimes:'
  puts i.downtimes

  puts 'list all Notifications:'
  puts i.notifications

  puts 'enable Notifications for host:'
  puts i.enable_host_notification( 'icinga2' )
  puts 'disable Notifications for host:'
  puts i.disable_host_notification( 'icinga2' )

  puts 'disable Notifications for host and services:'
  puts i.disable_service_notification( 'icinga2' )


end

# -----------------------------------------------------------------------------

# EOF
