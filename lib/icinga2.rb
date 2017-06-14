#!/usr/bin/ruby
# frozen_string_literal: true
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
require_relative 'icinga2/version'
require_relative 'icinga2/network'
require_relative 'icinga2/status'
require_relative 'icinga2/converts'
require_relative 'icinga2/tools'
require_relative 'icinga2/downtimes'
require_relative 'icinga2/notifications'
require_relative 'icinga2/hosts'
require_relative 'icinga2/hostgroups'
require_relative 'icinga2/services'
require_relative 'icinga2/servicegroups'
require_relative 'icinga2/users'
require_relative 'icinga2/usergroups'

# -------------------------------------------------------------------------------------------------------------------

module Icinga2

  class Client

    include Logging

    include Icinga2::Version
    include Icinga2::Network
    include Icinga2::Status
    include Icinga2::Converts
    include Icinga2::Tools
    include Icinga2::Downtimes
    include Icinga2::Notifications
    include Icinga2::Hosts
    include Icinga2::Hostgroups
    include Icinga2::Services
    include Icinga2::Servicegroups
    include Icinga2::Users
    include Icinga2::Usergroups


    def initialize( settings = {} )

      @icingaHost           = settings.dig(:icinga, :host)           || 'localhost'
      @icingaApiPort        = settings.dig(:icinga, :api, :port)     || 5665
      @icingaApiUser        = settings.dig(:icinga, :api, :user)
      @icingaApiPass        = settings.dig(:icinga, :api, :password)
      @icingaCluster        = settings.dig(:icinga, :cluster)        || false
      @icingaSatellite      = settings.dig(:icinga, :satellite)
      @icingaNotifications  = settings.dig(:icinga, :notifications)  || false

      @icingaApiUrlBase     = format( 'https://%s:%d', @icingaHost, @icingaApiPort )
      @nodeName             = Socket.gethostbyname( Socket.gethostname ).first

      date                 = '2017-06-08'

#       logger.info( '-----------------------------------------------------------------' )
#       logger.info( ' Icinga2 Management' )
#       logger.info( "  Version #{VERSION} (#{date})" )
#       logger.info( '  Copyright 2016-2017 Bodo Schulz' )
#       logger.info( "  Backendsystem #{@icingaApiUrlBase}" )
#       logger.info( format( '    cluster enabled: %s', @icingaCluster ? 'true' : 'false' ) )
#       logger.info( format( '    notifications enabled: %s', @icingaNotifications ? 'true' : 'false' ) )
#       if( @icingaCluster )
#         logger.info( format( '    satellite endpoint: %s', @icingaSatellite ) )
#       end
#       logger.info( '-----------------------------------------------------------------' )
#       logger.info( '' )
#
#       logger.debug( format( '  server   : %s', @icingaHost ) )
#       logger.debug( format( '  port     : %s', @icingaApiPort ) )
#       logger.debug( format( '  api url  : %s', @icingaApiUrlBase ) )
#       logger.debug( format( '  api user : %s', @icingaApiUser ) )
#       logger.debug( format( '  api pass : %s', @icingaApiPass ) )
#       logger.debug( format( '  node name: %s', @nodeName ) )

      @hasCert   = checkCert( user: @icingaApiUser, password: @icingaApiPass )
      @headers   = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      self

    end


    def checkCert( params = {} )

      nodeName     = params.dig(:nodeName) || 'localhost'

      user         = params.dig(:user)     || 'admin'
      password     = params.dig(:password) || ''

      # check whether pki files are there, otherwise use basic auth
      if File.file?( format( 'pki/%s.crt', nodeName ) )

        logger.debug( 'PKI found, using client certificates for connection to Icinga 2 API' )

        sslCertFile = File.read( format( 'pki/%s.crt', nodeName ) )
        sslKeyFile  = File.read( format( 'pki/%s.key', nodeName ) )
        sslCAFile   = File.read( 'pki/ca.crt' )

        cert      = OpenSSL::X509::Certificate.new( sslCertFile )
        key       = OpenSSL::PKey::RSA.new( sslKeyFile )

        @options   = {
          ssl_client_cert: cert,
          ssl_client_key: key,
          ssl_ca_file: sslCAFile,
          verify_ssl: OpenSSL::SSL::VERIFY_NONE
        }

        return true
      else

        logger.debug( 'PKI not found, using basic auth for connection to Icinga 2 API' )

        @options = {
          user: user,
          password: password,
          verify_ssl: OpenSSL::SSL::VERIFY_NONE
        }

        return false
      end

    end

  end
end

# EOF
