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

icingaHost         = ENV.fetch( 'ICINGA_HOST'             , 'icinga2' )
icingaApiPort      = ENV.fetch( 'ICINGA_API_PORT'         , 5665 )
icingaApiUser      = ENV.fetch( 'ICINGA_API_USER'         , 'admin' )
icingaApiPass      = ENV.fetch( 'ICINGA_API_PASSWORD'     , nil )
icingaCluster      = ENV.fetch( 'ICINGA_CLUSTER'          , false )
icingaSatellite    = ENV.fetch( 'ICINGA_CLUSTER_SATELLITE', nil )

# convert string to bool
icingaCluster   = icingaCluster.to_s.eql?('true') ? true : false

config = {
  icinga: {
    host: icingaHost,
    api: {
      port: icingaApiPort,
      user: icingaApiUser,
      password: icingaApiPass
    },
    cluster: icingaCluster,
    satellite: icingaSatellite
  }
}

# ---------------------------------------------------------------------------------------

i = Icinga2::Client.new( config )

unless( i.nil? )

  # run tests ...
  #
  #

  puts 'Information about Icinga2:'
  puts i.application_data
  puts i.cib_data()
  puts i.api_listener
  puts ''

  puts "check if Host 'icinga2-master' exists:"
  puts i.exists_host?( 'icinga2-master' ) ? 'true' : 'false'
  puts "get host Objects from 'icinga2-master'"
  puts i.host_objects
  puts 'Host problems:'
  puts i.host_problems
  puts 'Problem Hosts:'
  puts i.problem_hosts

  puts 'list named Hosts:'
  puts i.hosts( name: 'icinga2-master' )
  puts 'list all Hosts:'
  puts i.hosts
  puts ''

  puts "check if Hostgroup 'linux-servers' exists:"
  puts i.exists_hostgroup?( 'linux-servers' ) ? 'true' : 'false'
  puts "add hostgroup 'foo'"
  puts i.add_hostgroup( name: 'foo', display_name: 'FOO' )
  puts "list named Hostgroup 'foo'"
  puts i.hostgroups( name: 'foo' )
  puts 'list all Hostgroups:'
  puts i.list_hostgroups
  puts "delete Hostgroup 'foo'"
  puts i.delete_hostgroup( name: 'foo' )
  puts ''

  puts "check if service 'users' on host 'icinga2-master' exists:"
  puts i.existsService?( host: 'icinga2-master', service: 'users' )  ? 'true' : 'false'

  puts 'get service Objects'
  puts i.serviceObjects
  puts 'Service problems:'
  puts i.serviceProblems
  puts 'Problem Services:'
  puts i.problemServices

  puts "list named Service 'ping4' from Host 'icinga2-master'"
  puts i.listServices( host: 'icinga2-master', service: 'ping4' )
  puts 'list all Services:'
  puts i.listServices
  puts ''

  puts "check if Servicegroup 'disk' exists:"
  puts i.exists_servicegroup?( 'disk' ) ? 'true' : 'false'
  puts "add Servicegroup 'foo'"
  puts i.add_servicegroup( name: 'foo', display_name: 'FOO' )
  puts "list named Servicegroup 'foo'"
  puts i.servicegroups( name: 'foo' )
  puts 'list all Servicegroup:'
  puts i.list_servicegroups
  puts "delete Servicegroup 'foo'"
  puts i.delete_servicegroup( name: 'foo' )
  puts ''

  puts "check if Usergroup 'icingaadmins' exists:"
  puts i.existsUsergroup?( 'icingaadmins' ) ? 'true' : 'false'
  puts "add Usergroup 'foo'"
  puts i.addUsergroup( name: 'foo', display_name: 'FOO' )
  puts "list named Usergroup 'foo'"
  puts i.listUsergroups( name: 'foo' )
  puts 'list all Usergroup:'
  puts i.listUsergroups
  puts "delete Usergroup 'foo'"
  puts i.deleteUsergroup( name: 'foo' )
  puts ''

  puts "check if User 'icingaadmin' exists:"
  puts i.existsUser?( 'icingaadmin' ) ? 'true' : 'false'
  puts "add User 'foo'"
  puts i.addUser( name: 'foo', display_name: 'FOO', email: 'foo@bar.com', pager: '0000', groups: ['icingaadmins'] )
  puts "list named User 'foo'"
  puts i.listUsers( name: 'foo' )
  puts 'list all User:'
  puts i.listUsers
  puts "delete User 'foo'"
  puts i.deleteUser( name: 'foo' )
  puts ''

  puts "add Downtime 'test':"
  puts i.addDowntime( name: 'test', type: 'service', host: 'icinga2-master', comment: 'test downtime', author: 'icingaadmin', start_time: Time.now.to_i, end_time: Time.now.to_i + 20 )
  puts 'list all Downtimes:'
  puts i.listDowntimes

  puts 'list all Notifications:'
  puts i.listNotifications

  puts i.enableHostNotification( 'icinga2-master' )
  puts i.disableHostNotification( 'icinga2-master' )

 puts i.disableServiceNotification( 'icinga2-master' )


end

# -----------------------------------------------------------------------------

# EOF
