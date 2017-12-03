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

    i.cib_data

    puts ' ------------------------------------------------------------- '
    puts ''

    v, r = i.version.values
    l, e = i.average_statistics.values
    puts format( '= version: %s, revision %s', v, r )
    puts format( '= avg_latency: %s, avg_execution_time %s', l, e )
    puts format( '= start time: %s', i.start_time )
    puts format( '= uptime: %s', i.uptime )
    puts format( '= node name: %s', i.node_name )
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

    puts ' ------------------------------------------------------------- '
    puts ''

    rescue => e
      $stderr.puts( e )
      $stderr.puts( e.backtrace.join("\n") )
    end
end


# -----------------------------------------------------------------------------

# EOF
