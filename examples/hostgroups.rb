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

    puts '= check if Hostgroup \'linux-servers\' exists'
    puts i.exists_hostgroup?( 'linux-servers' ) ? 'true' : 'false'
    puts ''
    puts '= check if Hostgroup \'docker\' exists'
    puts i.exists_hostgroup?( 'docker' ) ? 'true' : 'false'
    puts ''
    puts '= list named Hostgroup \'linux-servers\''
    puts i.hostgroups( host_group: 'linux-servers' )
    puts ''
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

    puts ' ------------------------------------------------------------- '
    puts ''

    rescue => e
      $stderr.puts( e )
      $stderr.puts( e.backtrace.join("\n") )
    end
end


# -----------------------------------------------------------------------------

# EOF
