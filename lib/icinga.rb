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
require_relative 'message-queue'
require_relative 'icinga/version'
require_relative 'icinga/network'
require_relative 'icinga/status'
require_relative 'icinga/host'
require_relative 'icinga/service'
require_relative 'icinga/queue'

# -------------------------------------------------------------------------------------------------------------------

module Icinga

  class Client

    include Logging

    include Icinga::Version
    include Icinga::Network
    include Icinga::Status
    include Icinga::Host
    include Icinga::Service
    include Icinga::Queue

    def initialize( params = {} )

      @icingaHost       = params.dig(:icinga, :host)       || 'localhost'
      @icingaApiPort    = params.dig(:icinga, :api, :port) || 5665
      @icingaApiUser    = params.dig(:icinga, :api, :user)
      @icingaApiPass    = params.dig(:icinga, :api, :pass)
      @icingaCluster    = params.dig(:icinga, :cluster)    || false
      @icingaSatellite  = params.dig(:icinga, :satellite)
      mqHost            = params.dig(:mq, :host)
      mqPort            = params.dig(:mq, :port)
      mqQueue           = params.dig(:mq, :queue)

      @icingaApiUrlBase = sprintf( 'https://%s:%d', @icingaHost, @icingaApiPort )
      @nodeName         = Socket.gethostbyname( Socket.gethostname ).first

      @MQSettings = {
        :beanstalk => {
          :host  => mqHost,
          :port  => mqPort,
          :queue => mqQueue
        }
      }

      date                 = '2017-04-17'

      logger.info( '-----------------------------------------------------------------' )
      logger.info( ' Icinga2 Management' )
      logger.info( "  Version #{VERSION} (#{date})" )
      logger.info( '  Copyright 2016-2017 Bodo Schulz' )
      logger.info( "  Backendsystem #{@icingaApiUrlBase}" )
      logger.info( sprintf( '    cluster enabled: %s', @icingaCluster ? 'true' : 'false' ) )
      if( @icingaCluster )
        logger.info( sprintf( '    satellite endpoint: %s', @icingaSatellite ) )
      end
      if( mqHost != nil && mqPort != nil )
        logger.info( '  used Services:' )
        logger.info( "    - message Queue: #{mqHost}:#{mqPort}/#{mqQueue}" )
      end
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

      nodeName     = params.dig(:nodeName) || 'localhost'

      user         = params.dig(:user)     || 'admin'
      password     = params.dig(:password) || ''

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

      logger.debug( self.applicationData() )
      logger.debug( self.listHost( { :host => 'foo-bar.com' } ) )
      logger.debug( self.listHost() )

    end

  end
end

# EOF
