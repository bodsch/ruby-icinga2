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

    puts ' ==> USERS'
    puts ''

    ['icingaadmin', 'icinga-admin'].each do |h|
      e = i.exists_user?( h ) ? 'true' : 'false'
      puts format( '= check if User \'%s\' exists : %s', h, e )
    end
    puts ''

    puts '= add User \'foo\''
    puts i.add_user( user_name: 'foo', display_name: 'FOO', email: 'foo@bar.com', pager: '0000', groups: ['icingaadmins'] )
    puts ''
    puts '= add User \'foo\' (again)'
    puts i.add_user( user_name: 'foo', display_name: 'FOO', email: 'foo@bar.com', pager: '0000', groups: ['icingaadmins'] )
    puts ''

    puts '= list named User \'foo\''
    puts i.users( user_name: 'foo' )
    puts ''

    puts '= delete User \'foo\''
    puts i.delete_user( user_name: 'foo' )
    puts ''

    puts '= list all User'
    puts i.users
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
