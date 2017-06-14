
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

      @icinga_host           = settings.dig(:icinga, :host)           || 'localhost'
      @icinga_api_port       = settings.dig(:icinga, :api, :port)     || 5665
      @icinga_api_user       = settings.dig(:icinga, :api, :user)
      @icinga_api_pass       = settings.dig(:icinga, :api, :password)
      @icinga_cluster        = settings.dig(:icinga, :cluster)        || false
      @icinga_satellite      = settings.dig(:icinga, :satellite)
      @icinga_notifications  = settings.dig(:icinga, :notifications)  || false

      @icinga_api_url_base   = format( 'https://%s:%d', @icinga_host, @icinga_api_port )
      @node_name             = Socket.gethostbyname( Socket.gethostname ).first

      @has_cert   = cert?( user: @icinga_api_user, password: @icinga_api_pass )
      @headers    = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      self
    end


    def cert?( params = {} )

      node_name     = params.dig(:node_name) || 'localhost'

      user         = params.dig(:user)     || 'admin'
      password     = params.dig(:password) || ''

      # check whether pki files are there, otherwise use basic auth
      if File.file?( format( 'pki/%s.crt', node_name ) )

        logger.debug( 'PKI found, using client certificates for connection to Icinga 2 API' )

        ssl_cert_file = File.read( format( 'pki/%s.crt', node_name ) )
        ssl_key_file  = File.read( format( 'pki/%s.key', node_name ) )
        ssl_ca_file   = File.read( 'pki/ca.crt' )

        cert      = OpenSSL::X509::Certificate.new( ssl_cert_file )
        key       = OpenSSL::PKey::RSA.new( ssl_key_file )

        @options   = {
          ssl_client_cert: cert,
          ssl_client_key: key,
          ssl_ca_file: ssl_ca_file,
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
