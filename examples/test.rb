#!/usr/bin/env ruby
# frozen_string_literal: true
#
# 23.01.2017 - Bodo Schulz
#
#
# v0.9.2

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
    # examples from: https://github.com/saurabh-hirani/icinga2-api-examples
    #
    # Get display_name, check_command attribute for services applied for filtered hosts matching host.address == 1.2.3.4.
    # Join the output with the hosts on which these checks run (services are applied to hosts)
    #
    puts i.service_objects(
      attrs: %w[display_name check_command],
      filter: 'match("1.2.3.4",host.address)' ,
      joins: ['host.name', 'host.address']
    )
    puts ''
    # Get all services in critical state and filter out the ones for which active checks are disabled
    # service.states - 0 = OK, 1 = WARNING, 2 = CRITICAL
    #
    # { "joins": ['host.name', 'host.address'], "filter": "service.state==2", "attrs": ['display_name', 'check_command', 'enable_active_checks'] }
    puts i.service_objects(
      attrs: %w[display_name check_command enable_active_checks],
      filter: 'service.state==1',
      joins: ['host.name', 'host.address']
    )
    puts ''
    # Get host name, address of hosts belonging to a specific hostgroup
    puts i.host_objects(
      attrs: %w[display_name name address],
      filter: '"windows-servers" in host.groups'
    )

  rescue => e
    warn( e )
    warn( e.backtrace.join("\n") )
  end
end


# -----------------------------------------------------------------------------

# EOF
