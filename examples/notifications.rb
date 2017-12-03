#!/usr/bin/env ruby
# frozen_string_literal: true
#
# 07.10.2017 - Bodo Schulz
#
#
# Examples for Hostgroups

# -----------------------------------------------------------------------------

require_relative '../lib/icinga2'
require_relative 'config'

# -----------------------------------------------------------------------------

i = Icinga2::Client.new( @config )

unless( i.nil? )

  # run tests ...
  #
  #

  begin

    puts ' ------------------------------------------------------------- '
    puts ''

    puts ' ==> NOTIFICATIONS'
    puts ''
    puts '= list all Notifications'
    puts i.notifications
    puts ''

    ['c1-mysql-1', 'bp-foo'].each do |h|
      puts format( '= enable Notifications for \'%s\'', h )
      puts i.enable_host_notification( h )
    end
    puts ''

    ['c1-mysql-1', 'bp-foo'].each do |h|
      puts format( '= disable Notifications for \'%s\'', h )
      puts i.disable_host_notification( h )
    end
    puts ''

    ['c1-mysql-1', 'bp-foo'].each do |h|
      puts format( '= enable Notifications for \'%s\' and they services', h )
      puts i.enable_service_notification( h )
    end
    puts ''

    ['c1-mysql-1', 'bp-foo'].each do |h|
      puts format( '= disable Notifications for \'%s\' and they services', h )
      puts i.disable_service_notification( h )
    end
    puts ''

    puts '= enable Notifications for hostgroup'
    puts i.enable_hostgroup_notification( host_group: 'linux-servers')
    puts ''


    puts '= disable Notifications for hostgroup'
    puts i.disable_hostgroup_notification( host_group: 'linux-servers')
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
