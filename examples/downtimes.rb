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

#   puts ' ==> DOWNTIMES'
#   puts ''
#   puts 'add Downtime \'test\''
#   puts i.add_downtime( name: 'test', type: 'service', host: 'foo', comment: 'test downtime', author: 'icingaadmin', start_time: Time.now.to_i, end_time: Time.now.to_i + 20 )
#   puts ''
#   puts 'list all Downtimes'
#   puts i.downtimes
#   puts ''

    puts ' ------------------------------------------------------------- '
    puts ''

    rescue => e
      warn( e )
      warn( e.backtrace.join("\n") )
    end
end


# -----------------------------------------------------------------------------

# EOF
