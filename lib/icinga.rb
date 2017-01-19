#!/usr/bin/ruby
#
#
#
#

require 'rest-client'
require 'openssl'

require 'json'
require 'net/http'
require 'uri'

require_relative 'logging'
require_relative 'icinga/network'
require_relative 'icinga/application'
require_relative 'icinga/host'
require_relative 'icinga/service'
require_relative 'icinga/message-queue'

# -------------------------------------------------------------------------------------------------------------------

module Icinga

  class Client

    include Logging

    include Icinga::Network
    include Icinga::Application
    include Icinga::Host
    include Icinga::Service
    include Icinga::MessageQueue

    def initialize( params = {} )

      @icingaHost     = params[:icingaHost]     ? params[:icingaHost]     : 'localhost'
      @icingaApiPort  = params[:icingaApiPort]  ? params[:icingaApiPort]  : 5665
      @icingaApiUser  = params[:icingaApiUser]  ? params[:icingaApiUser]  : nil
      @icingaApiPass  = params[:icingaApiPass]  ? params[:icingaApiPass]  : nil
      mqHost          = params[:mqHost]         ? params[:mqHost]         : 'localhost'
      mqPort          = params[:mqPort]         ? params[:mqPort]         : 11300
      @mqQueue        = params[:mqQueue]        ? params[:mqQueue]        : 'mq-graphite'

      @icingaApiUrlBase = sprintf( 'https://%s:%d', @icingaHost, @icingaApiPort )
      @nodeName         = Socket.gethostbyname( Socket.gethostname ).first

      @MQSettings = {
        :beanstalkHost => mqHost,
        :beanstalkPort => mqPort
      }

      version              = '1.3.0-dev'
      date                 = '2017-01-15'

      logger.info( '-----------------------------------------------------------------' )
      logger.info( ' Icinga2 Management' )
      logger.info( "  Version #{version} (#{date})" )
      logger.info( '  Copyright 2016-2017 Bodo Schulz' )
      logger.info( "  Backendsystem #{@icingaApiUrlBase}" )
      logger.info( '  used Services:' )
#       logger.info( "    - graphite     : #{@graphiteURI}" )
      logger.info( "    - message Queue: #{mqHost}:#{mqPort}/#{@mqQueue}" )
      logger.info( '-----------------------------------------------------------------' )
      logger.info( '' )

      logger.debug( sprintf( '  server   : %s', @icingaHost ) )
      logger.debug( sprintf( '  port     : %s', @icingaApiPort ) )
      logger.debug( sprintf( '  api url  : %s', @icingaApiUrlBase ) )
      logger.debug( sprintf( '  api user : %s', @icingaApiUser ) )
      logger.debug( sprintf( '  api pass : %s', @icingaApiPass ) )
      logger.debug( sprintf( '  node name: %s', @nodeName ) )

      @hasCert   = self.checkCert( { :user => @icingaApiUser, :password =>  @icingaApiPass } )
      @headers   = { "Content-Type" => "application/json", "Accept" => "application/json" }

      return self

    end


    def checkCert( params = {} )

      nodeName     = params[:nodeName]       ? params[:nodeName]       : 'localhost'

      user         = params[:user]           ? params[:user]           : 'admin'
      password     = params[:password]       ? params[:password]       : ''

      # check whether pki files are there, otherwise use basic auth
      if File.file?( sprintf( 'pki/%s.crt', nodeName ) )

        logger.debug( "PKI found, using client certificates for connection to Icinga 2 API" )

        sslCertFile = File.read( sprintf( 'pki/%s.crt', nodeName ) )
        sslKeyFile  = File.read( sprintf( 'pki/%s.key', nodeName ) )
        sslCAFile   = File.read( 'pki/ca.crt' )

        cert      = OpenSSL::X509::Certificate.new( sslCertFile )
        key       = OpenSSL::PKey::RSA.new( sslKeyFile )

        @options   = {
          :ssl_client_cert => cert,
          :ssl_client_key  => key,
          :ssl_ca_file     => sslCAFile,
          :verify_ssl      => OpenSSL::SSL::VERIFY_NONE
        }

        return true
      else

        logger.debug( "PKI not found, using basic auth for connection to Icinga 2 API" )

        @options = {
          :user       => user,
          :password   => password,
          :verify_ssl => OpenSSL::SSL::VERIFY_NONE
        }

        return false
      end

    end



    def run()

#      logger.debug( self.addHost( { :host => 'monitoring-16-01' } ) )
#      logger.debug( self.addHost( { :host => 'moebius-ci-01' } ) )
#      logger.debug( self.addHost( { :host => 'moebius-ci-02' } ) )

      logger.debug( self.listHost( { :host => 'monitoring-16-01' } ) )
      logger.debug( self.listHost() )

    end

  end
end
# EOF
