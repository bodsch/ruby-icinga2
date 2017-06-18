
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
# Namespace for classes and modules that handle all Icinga2 API calls
module Icinga2

  # static variables for handled warning
  HANDLED_WARNING  = 1
  # static variables for handled critical
  HANDLED_CRITICAL = 2
  # static variables for handled unknown
  HANDLED_UNKNOWN  = 3

  # Abstract base class for the API calls.
  # Provides some helper methods
  #
  # @author Bodo Schulz
  #
  class Client

    attr_reader :version, :revision, :node_name, :start_time, :uptime
    attr_reader :hosts_up, :hosts_down, :hosts_in_downtime, :hosts_acknowledged
    attr_reader :hosts_all, :hosts_problems, :hosts_handled_warning_problems, :hosts_handled_critical_problems, :hosts_handled_unknown_problems
    attr_reader :hosts_handled_problems, :hosts_down_adjusted

    attr_reader :services_ok, :services_warning, :services_critical, :services_unknown, :services_in_downtime, :services_acknowledged
    attr_reader :services_all, :services_problems, :services_handled_warning_problems, :services_handled_critical_problems, :services_handled_unknown_problems
    attr_reader :services_warning_adjusted, :services_critical_adjusted, :services_unknown_adjusted
    attr_reader :hosts_active_checks_1min, :hosts_passive_checks_1min, :services_active_checks_1min, :services_passive_checks_1min



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

    # Returns a new instance of Client
    #
    # @param [Hash, #read] settings the settings for Icinga2
    # @option settings [String] :icinga, :host the Icinga2 Hostname (default: 'localhost')
    # @option settings [Integer] :icinga, :api, :port the Icinga2 API Port (default: 5665)
    # @option settings [String] :icinga, :api, :user the Icinga2 API User
    # @option settings [String] :icinga, :api, :password the Icinga2 API Password
    # @option settings [Bool] :icinga, :cluster Icinga2 Cluster Mode
    # @option settings [Bool] :icinga, :notifications enable Icinga2 Host Notifications (default: false)
    #
    # @example to create an new Instance
    #    config = {
    #      icinga: {
    #        host: '192.168.33.5',
    #        api: {
    #          port: 5665,
    #          user: 'root',
    #          password: 'icinga'
    #        },
    #        cluster: false,
    #        satellite: true
    #      }
    #    }
    #
    #    @icinga = Icinga2::Client.new(config)
    #
    # @return [instance, #read]
    #
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


      @version = @revision = 0
      @node_name = @start_time = @uptime = ''
      @avg_latency = @avg_execution_time = 0
      @hosts_up = @hosts_down = @hosts_in_downtime = @hosts_acknowledged = 0
      @hosts_all = @hosts_problems = @hosts_handled_warning_problems = @hosts_handled_critical_problems = @hosts_handled_unknown_problems = 0
      @hosts_handled_problems = @hosts_down_adjusted = 0
      @services_ok = @services_warning = @services_critical = @services_unknown = @services_in_downtime = @services_acknowledged = 0
      @services_all = @services_problems = @services_handled_warning_problems = @services_handled_critical_problems = @services_handled_unknown_problems = 0
      @services_warning_adjusted = @services_critical_adjusted = @services_unknown_adjusted = 0
      @hosts_active_checks_1min = @hosts_passive_checks_1min = @services_active_checks_1min = @services_passive_checks_1min = 0

      extract_data

      self
    end

    # @param [Hash, #read] params create a HTTP Header based on a Icinga2 Certificate or an User PAI Login
    # @option params [String] :node_name the Icinga2 Hostname (default: 'localhost')
    # @option params [Integer] :user the Icinga2 API User
    # @option params [Integer] :password the Icinga2 API Password
    # @example with Certificate
    #    @icinga.cert?(name_name: 'icinga2-dashing')
    #
    # @example with User
    #    @icinga.cert?(user: 'root', password: 'icinga')
    #
    # @return [Bool, #read]
    #
    def cert?( params = {} )

      node_name    = params.dig(:node_name) || 'localhost'
      user         = params.dig(:user)
      password     = params.dig(:password)

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
