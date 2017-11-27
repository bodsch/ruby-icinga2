
require_relative 'version'
require_relative 'network'
require_relative 'statistics'
require_relative 'converts'
require_relative 'tools'
require_relative 'downtimes'
require_relative 'notifications'
require_relative 'hosts'
require_relative 'hostgroups'
require_relative 'services'
require_relative 'servicegroups'
require_relative 'users'
require_relative 'usergroups'

# -------------------------------------------------------------------------------------------------------------------
#
# @abstract # Namespace for classes and modules that handle all Icinga2 API calls
#
# @author Bodo Schulz <bodo@boone-schulz.de>
#
#
module Icinga2

  # static variable for hosts down
  HOSTS_DOWN     = 1
  # static variable for hosts critical
  HOSTS_CRITICAL = 2
  # static variable for hosts unknown
  HOSTS_UNKNOWN  = 3

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

    include Logging

    include Icinga2::Network
    include Icinga2::Statistics
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

      icinga_host           = settings.dig(:icinga, :host)           || 'localhost'
      icinga_api_port       = settings.dig(:icinga, :api, :port)     || 5665
      icinga_api_user       = settings.dig(:icinga, :api, :user)
      icinga_api_pass       = settings.dig(:icinga, :api, :password)
      icinga_api_version    = settings.dig(:icinga, :api, :version)  || 1
      icinga_api_pki_path   = settings.dig(:icinga, :api, :pki_path)
      icinga_api_node_name  = settings.dig(:icinga, :api, :node_name)
      @icinga_cluster       = settings.dig(:icinga, :cluster)        || false
      @icinga_satellite     = settings.dig(:icinga, :satellite)
      @icinga_notifications = settings.dig(:icinga, :notifications)  || false

      @last_call_timeout    = 320
      @last_cib_data_called = 0
      @last_status_data_called = 0
      @last_application_data_called = 0
      @last_service_objects_called = 0
      @last_host_objects_called = 0

      @icinga_api_url_base  = format( 'https://%s:%d/v%s', icinga_host, icinga_api_port, icinga_api_version )

      _has_cert, @options = cert?(
        pki_path: icinga_api_pki_path,
        node_name: icinga_api_node_name,
        user: icinga_api_user,
        password: icinga_api_pass
      )

      @headers    = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

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

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      pki_path     = params.dig(:pki_path)
      node_name    = params.dig(:node_name)
      user         = params.dig(:user)
      password     = params.dig(:password)

      if( node_name.nil? )
        begin
          node_name = Socket.gethostbyname(Socket.gethostname).first
          logger.debug(format('node name: %s', node_name))
        rescue SocketError => e

          raise format("can't resolve hostname (%s)", e)
        end
      end

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

    # return Icinga2 Application data
    #
    # @example
    #    @icinga.application_data
    #
    # @return [Hash]
    #
    def application_data

      data = icinga_application_data(
        url: format( '%s/status/IcingaApplication', @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )

      #puts '---'
      #puts data
      #puts data.class.to_s
      #puts '---'

      return nil if( data.nil? )
#      return data if( data.is_a?(Hash) && data.dig('code').to_i != 200 )
#puts '.'

      app_data = data.dig('icingaapplication','app')

      #puts '---'
      #puts app_data
      #puts app_data.class.to_s
      #puts '---'

      # version and revision
      @version, @revision = parse_version(app_data.dig('version'))

      #   - node_name
      @node_name = app_data.dig('node_name')

      #   - start_time
      @start_time = Time.at(app_data.dig('program_start').to_f)

      data
    end

    # return Icinga2 CIB
    #
    # @example
    #    @icinga.cib_data
    #
    # @return [Hash]
    #
    def cib_data

      data = icinga_application_data(
        url: format( '%s/status/CIB', @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )

      return nil if( data.nil? )

      @last_cib_data_called = 0 #Time.now.to_i

      if( data.is_a?(Hash))

        cib_data = data.clone

        # extract
        #   - uptime
        uptime   = cib_data.dig('uptime').round(2)
        @uptime  = Time.at(uptime).utc.strftime('%H:%M:%S')
        #   - avg_latency / avg_execution_time
        @avg_latency        = cib_data.dig('avg_latency').round(2)
        @avg_execution_time = cib_data.dig('avg_execution_time').round(2)

        #   - hosts
        @hosts_up           = cib_data.dig('num_hosts_up').to_i
        @hosts_down         = cib_data.dig('num_hosts_down').to_i
        @hosts_pending      = cib_data.dig('num_hosts_pending').to_i
        @hosts_unreachable  = cib_data.dig('num_hosts_unreachable').to_i
        @hosts_in_downtime  = cib_data.dig('num_hosts_in_downtime').to_i
        @hosts_acknowledged = cib_data.dig('num_hosts_acknowledged').to_i

        #   - services
        @services_ok           = cib_data.dig('num_services_ok').to_i
        @services_warning      = cib_data.dig('num_services_warning').to_i
        @services_critical     = cib_data.dig('num_services_critical').to_i
        @services_unknown      = cib_data.dig('num_services_unknown').to_i
        @services_pending      = cib_data.dig('num_services_pending').to_i
        @services_in_downtime  = cib_data.dig('num_services_in_downtime').to_i
        @services_acknowledged = cib_data.dig('num_services_acknowledged').to_i

        #   - check stats
        @hosts_active_checks_1min     = cib_data.dig('active_host_checks_1min')
        @hosts_passive_checks_1min    = cib_data.dig('passive_host_checks_1min')
        @services_active_checks_1min  = cib_data.dig('active_service_checks_1min')
        @services_passive_checks_1min = cib_data.dig('passive_service_checks_1min')

      end

      data
    end

    # return Icinga2 Status Data
    #
    # @example
    #    @icinga.status_data
    #
    # @return [Hash]
    #
    def status_data

      @last_status_data_called = Time.now.to_i

      icinga_application_data(
        url: format( '%s/status', @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )
    end

    # return Icinga2 API Listener
    #
    # @example
    #    @icinga.api_listener
    #
    # @return [Hash]
    #
    def api_listener

      @last_application_data_called = Time.now.to_i

      icinga_application_data(
        url: format( '%s/status/ApiListener', @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )
    end

    # check the availability of a Icinga network connect
    #
    # @example
    #    @icinga.available?
    #
    # @return [Bool]
    #
    def available?

      data = application_data

      return true unless( data.nil? )

      false
    end

    # return Icinga2 version and revision
    #
    # @example
    #    @icinga.version.values
    #
    #    v = @icinga.version
    #    version = v.dig(:version)
    #
    # @return [Hash]
    #    * version
    #    * revision
    #
    def version

      application_data if((Time.now.to_i - @last_application_data_called).to_i > @last_call_timeout)

      version  = @version.nil?  ? 0 : @version
      revision = @revision.nil? ? 0 : @revision

      {
        version: version.to_s,
        revision: revision.to_s
      }
    end

    # return Icinga2 node_name
    #
    # @example
    #    @icinga.node_name
    #
    # @return [String]
    #
    def node_name

      application_data if((Time.now.to_i - @last_application_data_called).to_i > @last_call_timeout)

      return @node_name if( @node_name )

      nil
    end

    # return Icinga2 start time
    #
    # @example
    #    @icinga.start_time
    #
    # @return [String]
    #
    def start_time

      application_data if((Time.now.to_i - @last_application_data_called).to_i > @last_call_timeout)

      return @start_time if( @start_time )

      nil
    end

    # return Icinga2 uptime
    #
    # @example
    #    @icinga.cib_data
    #    @icinga.uptime
    #
    # @return [String]
    #
    def uptime

      cib_data if((Time.now.to_i - @last_cib_data_called).to_i > @last_call_timeout)

      return @uptime if( @uptime )

      nil
    end

  end
end
