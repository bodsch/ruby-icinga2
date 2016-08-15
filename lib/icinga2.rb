#!/usr/bin/ruby
#
#
#
#

require 'rest-client'
require 'openssl'
require 'logger'
require 'json'
require 'net/http'
require 'uri'


# -------------------------------------------------------------------------------------------------------------------

class Icinga2

  attr_reader :version
  attr_reader :nodeName
  attr_reader :app_starttime

  attr_reader :uptime
  attr_reader :avg_latency
  attr_reader :avg_execution_time
  attr_reader :services_ok
  attr_reader :services_pending
  attr_reader :services_critical
  attr_reader :services_warning
  attr_reader :services_unknown
  attr_reader :services_unknown
  attr_reader :services_downtime

  attr_reader :hosts_up
  attr_reader :hosts_down
  attr_reader :hosts_ack
  attr_reader :hosts_downtime

  attr_reader :status_hosts

  attr_reader :total_critical
  attr_reader :total_warning

  attr_reader :fullAppData
  attr_reader :fullStatsData
  attr_reader :fullApiData

  def initialize( serverName, serverPort = 5665, apiUser = nil, apiPass = nil )

    file = File.open( '/tmp/monitoring-icinga2.log', File::WRONLY | File::APPEND | File::CREAT )
    file.sync = true
    @log = Logger.new( file, 'weekly', 1024000 )
#    @log = Logger.new( STDOUT )
    @log.level = Logger::DEBUG
    @log.datetime_format = "%Y-%m-%d %H:%M:%S"
    @log.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime.strftime(@log.datetime_format)}] #{severity.ljust(5)} : #{msg}\n"
    end

    @apiUrlBase  = sprintf( 'https://%s:%d', serverName, serverPort )
    @apiUser     = apiUser
    @apiPass     = apiPass
    @nodeName    = Socket.gethostbyname( Socket.gethostname ).first

    @log.debug( sprintf( '  server   : %s', serverName ) )
    @log.debug( sprintf( '  port     : %s', serverPort ) )
    @log.debug( sprintf( '  api url  : %s', @apiUrlBase ) )
    @log.debug( sprintf( '  api user : %s', @apiUser ) )
    @log.debug( sprintf( '  api pass : %s', @apiPass ) )
    @log.debug( sprintf( '  node name: %s', @nodeName ) )

    @hasCert = false

    checkCert()

    @headers     = {
      'Content-Type' => 'application/json',
      'Accept'       => 'application/json'
    }
  end


  def checkCert()

    # check whether pki files are there, otherwise use basic auth
    if File.file?( sprintf( 'pki/%s.crt', @nodeName ) )

      @log.debug( "PKI found, using client certificates for connection to Icinga 2 API" )

      cert_file = File.read( sprintf( 'pki/%s.crt', @nodeName ) )
      key_file  = File.read( sprintf( 'pki/%s.key', @nodeName ) )
      ca_file   = File.read( 'pki/ca.crt' )

      cert      = OpenSSL::X509::Certificate.new( cert_file )
      key       = OpenSSL::PKey::RSA.new( key_file )

      @options   = {
        :ssl_client_cert => cert,
        :ssl_client_key  => key,
        :ssl_ca_file     => ca_file,
        :verify_ssl      => OpenSSL::SSL::VERIFY_NONE
      }

      @hasCert = true
    else

      @log.debug( "PKI not found, using basic auth for connection to Icinga 2 API" )

      @options = {
        :user       => @apiUser,
        :password   => @apiPass,
        :verify_ssl => OpenSSL::SSL::VERIFY_NONE
      }

      @hasCert = false
    end

  end


  def applicationData()

    apiUrl     = sprintf( '%s/v1/status/IcingaApplication', @apiUrlBase )
    restClient = RestClient::Resource.new( URI.encode( apiUrl ), @options )
    data       = JSON.parse( restClient.get( @headers ).body )
    result     = data['results'][0]['status'] # there's only one row

    return result

  end


  def addHost( host, vars = {} )

    # build FQDN
    fqdn = Socket.gethostbyname( host ).first

    payload = {
      "templates" => [ "generic-host" ],
      "attrs" => {
        "address"      => fqdn,
        "display_name" => host
      }
    }

    if( ! vars.empty? )
      payload['attrs']['vars'] = vars
    end

    restClient = RestClient::Resource.new(
      URI.encode( sprintf( '%s/v1/objects/hosts/%s', @apiUrlBase, host ) ),
      @options
    )

    begin
      data = restClient.put(
        JSON.generate( payload ),
        @headers
      )

      data   = JSON.parse( data )
      result = data['results'][0] ? data['results'][0] : nil

      if( result != nil )

        result = {
          :status       => 200,
          :name        => host,
          :message     => result['status']
        }

      end

    rescue => e

      error  = JSON.parse( e.response )
      @log.debug( error )
      result = error['results'][0] ? error['results'][0] : error

      result = {
        :status      => result['code'].to_i,
        :name        => host,
        :message     => result['status']
      }
    end

    return result

  end


  def deleteHost( host )

    result = ''

    @headers['X-HTTP-Method-Override'] = 'DELETE'

    restClient = RestClient::Resource.new(
      URI.encode( sprintf( '%s/v1/objects/hosts/%s?cascade=1', @apiUrlBase, host ) ),
      @options
    )

    begin
      data   = restClient.get( @headers )
      data   = JSON.parse( data )
      result = data['results'][0] ? data['results'][0] : nil

      if( result != nil )

        result = {
          :status       => 200,
          :name        => host,
          :message     => result['status']
        }

      end
    rescue => e

      error = JSON.parse( e.response )

      result = {
        :status      => error['error'].to_i,
        :name        => host,
        :message     => error['status']
      }
    end

    return result

  end


  def listHost( host = nil )

    code        = nil
    result      = {}

    restClient = RestClient::Resource.new(
      URI.encode( sprintf( '%s/v1/objects/hosts/%s', @apiUrlBase, host ) ),
      @options
    )

    begin
      data     = restClient.get( @headers )

      results  =  JSON.parse( data.body )['results']

#      @log.info( sprintf '%d hosts in monitoring', results.count() )

      result[:status] = 200

      results.each do |r|

        attrs = r['attrs'] ?  r['attrs'] : nil

        result[attrs['name']] = {
          :name         => attrs['name'],
          :display_name => attrs['display_name'],
          :type         => attrs['type']
        }

      end

    rescue => e

      error = JSON.parse( e.response )

      result = {
        :status      => error['error'].to_i,
        :name        => host,
        :message     => error['status']
      }
    end

    return result
  end


  def addServices( host, services = {} )

    def updateHost( hash, host )

      hash.each do |k, v|
        if k == "host" && v.is_a?( String )
          v.replace( host )
        elsif v.is_a?( Hash )
          updateHost( v, host )
        elsif v.is_a?(Array)
          v.flatten.each { |x| updateHost( x, host ) if x.is_a?(Hash) }
        end
      end

      hash
    end

    fqdn = Socket.gethostbyname( host ).first

    restClient = RestClient::Resource.new(
      URI.encode( sprintf( '%s/v1/objects/hosts/%s', @apiUrlBase, host ) ),
      @options
    )

    services.each do |s,v|

      @log.debug( s )
      @log.debug( v.to_json )

      restClient = RestClient::Resource.new(
        URI.encode( sprintf( '%s/v1/objects/services/%s!%s', @apiUrlBase, host, s ) ),
        @options
      )

      payload = {
        "templates" => [ "generic-service" ],
        "attrs"     => updateHost( v, host )
      }

      @log.debug( JSON.pretty_generate( payload ) )

       data = restClient.put(
         JSON.generate( ( payload ) ),
         @headers
       )

    end

  end

end

# EOF
