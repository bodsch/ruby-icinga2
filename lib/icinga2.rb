
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

  # static variable for hosts down
  HOSTS_DOWN = 1

  # static variables for handled warning
  SERVICE_STATE_WARNING  = 1
  # static variables for handled critical
  SERVICE_STATE_CRITICAL = 2
  # static variables for handled unknown
  SERVICE_STATE_UNKNOWN  = 3

  # Abstract base class for the API calls.
  # Provides some helper methods
  #
  # @author Bodo Schulz
  #
  class Client

    attr_reader :version, :revision, :node_name, :start_time, :uptime
    attr_reader :avg_latency, :avg_execution_time
    attr_reader :hosts_up, :hosts_down, :hosts_in_downtime, :hosts_acknowledged
    attr_reader :hosts_all, :hosts_problems, :hosts_problems_down, :hosts_handled_warning_problems, :hosts_handled_critical_problems, :hosts_handled_unknown_problems
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
    # @option settings [String] :host ('localhost') the Icinga2 Hostname
    # @option settings [Integer] :port (5665) the Icinga2 API Port
    # @option settings [String] :user the Icinga2 API User
    # @option settings [String] :password the Icinga2 API Password
    # @option settings [Integer] :version (1) the Icinga2 API Version
    # @option settings [Bool] :cluster Icinga2 Cluster Mode
    # @option settings [Bool] :notifications (false) enable Icinga2 Host Notifications
    #
    # @example to create an new Instance
    #    config = {
    #      icinga: {
    #        host: '192.168.33.5',
    #        api: {
    #          port: 5665,
    #          user: 'root',
    #          password: 'icinga',
    #          version: 1
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
    def initialize( settings )

      raise ArgumentError.new('only Hash are allowed') unless( settings.is_a?(Hash) )
      raise ArgumentError.new('missing settings') if( settings.size.zero? )

      @icinga_host           = settings.dig(:icinga, :host)           || 'localhost'
      @icinga_api_port       = settings.dig(:icinga, :api, :port)     || 5665
      @icinga_api_user       = settings.dig(:icinga, :api, :user)
      @icinga_api_pass       = settings.dig(:icinga, :api, :password)
      @icinga_api_version    = settings.dig(:icinga, :api, :version)  || 1
      @icinga_api_pki_path   = settings.dig(:icinga, :api, :pki_path)
      @icinga_api_node_name  = settings.dig(:icinga, :api, :node_name)

      @icinga_cluster        = settings.dig(:icinga, :cluster)        || false
      @icinga_satellite      = settings.dig(:icinga, :satellite)
      @icinga_notifications  = settings.dig(:icinga, :notifications)  || false

      @icinga_api_url_base   = format( 'https://%s:%d/v%s', @icinga_host, @icinga_api_port, @icinga_api_version )
      @icinga_api_node_name  = Socket.gethostbyname( Socket.gethostname ).first if( @icinga_api_node_name.nil? )

      @has_cert, @options = cert?(
        pki_path: @icinga_api_pki_path,
        node_name: @icinga_api_node_name,
        user: @icinga_api_user,
        password: @icinga_api_pass
      )

      @headers    = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

      @version = @revision = 0
      @node_name = @start_time = @uptime = ''
      @avg_latency = @avg_execution_time = 0
      @hosts_up = @hosts_down = @hosts_in_downtime = @hosts_acknowledged = 0
      @hosts_all = @hosts_problems = @hosts_problems_down = @hosts_handled_warning_problems = @hosts_handled_critical_problems = @hosts_handled_unknown_problems = 0
      @hosts_handled_problems = @hosts_down_adjusted = 0
      @services_ok = @services_warning = @services_critical = @services_unknown = @services_in_downtime = @services_acknowledged = 0
      @services_all = @services_problems = @services_handled_warning_problems = @services_handled_critical_problems = @services_handled_unknown_problems = 0
      @services_warning_adjusted = @services_critical_adjusted = @services_unknown_adjusted = 0
      @hosts_active_checks_1min = @hosts_passive_checks_1min = @services_active_checks_1min = @services_passive_checks_1min = 0

      self
    end

    # create a HTTP Header based on a Icinga2 Certificate or an User API Login
    #
    # @param [Hash, #read] params
    # @option params [String] :pki_path the location of the Certificate Files
    # @option params [String] :node_name the Icinga2 Hostname
    # @option params [String] :user the Icinga2 API User
    # @option params [String] :password the Icinga2 API Password
    #
    # @example with Certificate
    #    @icinga.cert?(pki_path: '/etc/icinga2', node_name: 'icinga2-dashing')
    #
    # @example with User
    #    @icinga.cert?(user: 'root', password: 'icinga')
    #
    # @return [Bool, #read]
    #
    def cert?( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      pki_path     = params.dig(:pki_path)
      node_name    = params.dig(:node_name)
      user         = params.dig(:user)
      password     = params.dig(:password)

      ssl_cert_file = format( '%s/%s.crt', pki_path, node_name )
      ssl_key_file  = format( '%s/%s.key', pki_path, node_name )
      ssl_ca_file   = format( '%s/ca.crt', pki_path )

      if( File.file?( ssl_cert_file ) && File.file?( ssl_key_file ) && File.file?( ssl_ca_file ) )

        logger.debug( 'PKI found, using client certificates for connection to Icinga 2 API' )

        ssl_cert_file = File.read( ssl_cert_file )
        ssl_key_file  = File.read( ssl_key_file )
        ssl_ca_file   = File.read( ssl_ca_file )

        cert          = OpenSSL::X509::Certificate.new( ssl_cert_file )
        key           = OpenSSL::PKey::RSA.new( ssl_key_file )

        [true, {
          ssl_client_cert: cert,
          ssl_client_key: key,
          ssl_ca_file: ssl_ca_file,
          verify_ssl: OpenSSL::SSL::VERIFY_NONE
        } ]

      else

        logger.debug( 'PKI not found, using basic auth for connection to Icinga 2 API' )

        raise ArgumentError.new('Missing user_name') if( user.nil? )
        raise ArgumentError.new('Missing password')  if( password.nil? )

        [false, {
          user: user,
          password: password,
          verify_ssl: OpenSSL::SSL::VERIFY_NONE
        } ]
      end

    end

  end
end

