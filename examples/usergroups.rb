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

    puts ' ==> USERGROUPS'
    puts ''

    ['icingaadmins', 'linux-admins'].each do |h|
      e = i.exists_usergroup?( h ) ? 'true' : 'false'
      puts format( '= check if Usergroup \'%s\' exists : %s', h, e )
    end
    puts ''

    puts '= add Usergroup \'foo\''
    puts i.add_usergroup( user_group: 'foo', display_name: 'FOO' )
    puts ''

    puts 'list named Usergroup \'foo\''
    puts i.usergroups( user_group: 'foo' )
    puts ''

    puts '= delete Usergroup \'foo\''
    puts i.delete_usergroup( user_group: 'foo' )
    puts ''


    puts 'list all Usergroup'
    puts i.usergroups
    puts ''
    puts ' ------------------------------------------------------------- '
    puts ''

    rescue => e
      warn( e )
      warn( e.backtrace.join("\n") )
    end
end


# -----------------------------------------------------------------------------

# EOF
