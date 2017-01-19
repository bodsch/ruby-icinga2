#!/usr/bin/ruby
#
# 03.01.2017 - Bodo Schulz
#
#
# v0.7.0

# -----------------------------------------------------------------------------

require 'yaml'

require_relative '../lib/icinga'
require_relative '../lib/message-queue'

# -----------------------------------------------------------------------------

logDirectory     = '/var/log/monitoring'

icingaHost      = ENV['ICINGA_HOST']         ? ENV['ICINGA_HOST']          : 'localhost'
icingaApiPort   = ENV['ICINGA_API_PORT']     ? ENV['ICINGA_API_PORT']      : 5665
icingaApiUser   = ENV['ICINGA_API_USER']     ? ENV['ICINGA_API_USER']      : 'admin'
icingaApiPass   = ENV['ICINGA_API_PASSWORD'] ? ENV['ICINGA_API_PASSWORD']  : nil
mqEnabled       = ENV['MQ_ENABLED']          ? ENV['MQ_ENABLED']           : false
mqHost          = ENV['MQ_HOST']             ? ENV['MQ_HOST']              : 'localhost'
mqPort          = ENV['MQ_PORT']             ? ENV['MQ_PORT']              : 11300
mqQueue         = ENV['MQ_QUEUE']            ? ENV['MQ_QUEUE']             : 'mq-icinga'

config = {
  :icingaHost     => icingaHost,
  :icingaApiPort  => icingaApiPort,
  :icingaApiUser  => icingaApiUser,
  :icingaApiPass  => icingaApiPass,
  :mqHost         => mqHost,
  :mqPort         => mqPort,
  :mqQueue        => mqQueue
}



# ---------------------------------------------------------------------------------------

i = Icinga::Client.new( config )

# ---------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------

# NEVER FORK THE PROCESS!
# the used supervisord will control all
stop = false

Signal.trap('INT')  { stop = true }
Signal.trap('HUP')  { stop = true }
Signal.trap('TERM') { stop = true }
Signal.trap('QUIT') { stop = true }

if( i != nil )
  i.run()
end

# until stop
#   # do your thing
#   if( mqEnabled == true )
#
#     queue()
#   else
#
#     i.run()
#   end
#   sleep( 15 )
# end

# -----------------------------------------------------------------------------

# EOF
