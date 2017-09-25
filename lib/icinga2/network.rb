
# frozen_string_literal: true
module Icinga2

  # namespace for network handling
  module Network

    # static function for GET Requests
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :url
    # @option params [String] :headers
    # @option params [String] :options
    # @option params [Hash] :payload
    #
    #
    # @return [Hash]
    #
    def self.api_data( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload) || {}

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )
      raise ArgumentError.new('only Hash for payload are allowed') unless( payload.is_a?(Hash) )

      rest_client = RestClient::Resource.new( URI.encode( url ), options )

      max_retries = 10
      retried     = 0

      begin
        if payload
          headers['X-HTTP-Method-Override'] = 'GET'
          payload = JSON.generate(payload)
          res = rest_client.post(payload, headers)
        else
          res = rest_client.get(headers)
        end

      rescue RestClient::Unauthorized => e

        return {
          status: 401,
          message: 'unauthorized'
        }

      rescue RestClient::NotFound => e

        message = format( 'not found (request %s)', url )
#         $stderr.puts( message )

        return {
          status: 404,
          message: message
        }

      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e

        if( retried < max_retries )
          retried += 1
          $stderr.puts(format("Cannot execute request against '%s': '%s' (retry %d / %d)", url, e, retried, max_retries))
          sleep(2)
          retry
        else

          message = format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url )
#           $stderr.puts( message )

          return {
            status: 500,
            message: message
          }
        end
      end

      body = res.body
      JSON.parse(body)
    end

    # static function for GET Requests without filters
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :url
    # @option params [String] :headers
    # @option params [String] :options
    # @option params [Hash] :payload
    #
    #
    # @return [Hash]
    #
    def self.application_data( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )

      data    = Network.api_data( url: url, headers: headers, options: options )

      return nil unless( data.dig(:status).nil? )

      results = data.dig('results')

      return results.first.dig('status') unless( results.nil? )
    end

    # static function for POST Requests
    #
    # @param [Hash] params
    # @option params [String] :url
    # @option params [String] :headers
    # @option params [String] :options
    # @option params [Hash] :payload
    #
    #
    # @return [Hash]
    #
    def self.post( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload)

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )
      raise ArgumentError.new('only Hash for payload are allowed') unless( payload.is_a?(Hash) )

      max_retries = 30
      retried     = 0
      result      = {}

      headers['X-HTTP-Method-Override'] = 'POST'

      rest_client = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin

        data = rest_client.post(
          JSON.generate( payload ),
          headers
        )

        data    = JSON.parse( data )
        results = data.dig('results').first

        return { status: results.dig('code').to_i, name: results.dig('name'), message: results.dig('status') } unless( results.nil? )

      rescue RestClient::ExceptionWithResponse => e

        error  = e.response ? e.response : nil
        error = JSON.parse( error ) if  error.is_a?( String )

        results = error.dig( 'results' )

        if( !results.nil? )

#           result = result.first

          return {
            status: results.dig('code').to_i,
            name: results.dig('name'),
            message: results.dig('status'),
            error: results.dig('errors')
          }
        else
          return {
            status: error.dig( 'error' ).to_i,
            message: error.dig( 'status' )
          }
        end

      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e

        if( retried < max_retries )
          retried += 1
          $stderr.puts(format("Cannot execute request against '%s': '%s' (retry %d / %d)", url, e, retried, max_retries))
          sleep(2)
          retry
        else

          message = format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url )
          $stderr.puts( message )

          return {
            status: 500,
            message: message
          }
        end
      end

      result
    end

    # static function for PUT Requests
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :url
    # @option params [String] :headers
    # @option params [String] :options
    # @option params [Hash] :payload
    #
    #
    # @return [Hash]
    #
    def self.put( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload)

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )
      raise ArgumentError.new('only Hash for payload are allowed') unless( payload.is_a?(Hash) )

      max_retries = 30
      retried     = 0
      result      = {}

      headers['X-HTTP-Method-Override'] = 'PUT'

      rest_client = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin
        data = rest_client.put(
          JSON.generate( payload ),
          headers
        )
        data    = JSON.parse( data )
        results = data.dig('results').first

        return { status: results.dig('code').to_i, message: results.dig('status') } unless( results.nil? )

      rescue RestClient::ExceptionWithResponse => e

        error  = e.response ? e.response : nil
        error = JSON.parse( error ) if  error.is_a?( String )

        results = error.dig('results')

        return { status: error.dig('error').to_i, message: error.dig('status'), error: results } if( results.nil? )

        if( results.is_a?( Hash ) && results.count != 0 )

          return {
            status: results.dig('code').to_i,
            name: results.dig('name'),
            message: results.dig('status'),
            error: results
          }
        else
          return {
            status: results.first.dig('code').to_i,
            message: format('%s (possible, object already exists)', results.first.dig('status') ),
            error: results
          }
        end

      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e

        if( retried < max_retries )
          retried += 1
          $stderr.puts(format("Cannot execute request against '%s': '%s' (retry %d / %d)", url, e, retried, max_retries))
          sleep(2)
          retry
        else

          message = format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url )
          $stderr.puts( message )

          return {
            status: 500,
            message: message
          }
        end
      end

      result
    end

    # static function for DELETE Requests
    #
    # @param [Hash] params
    # @option params [String] :url
    # @option params [String] :headers
    # @option params [String] :options
    #
    #
    # @return [Hash]
    #
    def self.delete( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )

      max_retries = 3
      retried     = 0

      headers['X-HTTP-Method-Override'] = 'DELETE'

      result  = {}

      rest_client = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin
        data     = rest_client.get( headers )

        if( data )

          data    = JSON.parse( data )
          results = data.dig('results').first

          return { status: results.dig('code').to_i, name: results.dig('name'), message: results.dig('status') } unless( results.nil? )
        end

      rescue RestClient::ExceptionWithResponse => e

        error  = e.response ? e.response : nil

        error = JSON.parse( error ) if  error.is_a?( String )

        results = error.dig('results')

        if( results.nil? )
          return {
            status: error.dig( 'error' ).to_i,
            message: error.dig( 'status' )
          }
        else

          results = results.first if( results.is_a?(Array) )
#          puts results
#          puts results.first.dig('code')
#           result_code = results.dig('code').to_i
#           result_name = results.dig('name')
#           result_status = results.dig('status')

          return {
            status: results.dig('code').to_i,
            name: results.dig('name'),
            message: results.dig('status'),
            error: results.dig('errors')
          }
        end
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e

        if( retried < max_retries )
          retried += 1
          $stderr.puts(format("Cannot execute request against '%s': '%s' (retry %d / %d)", url, e, retried, max_retries))
          sleep(2)
          retry
        else

          message = format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url )
          $stderr.puts( message )

          return {
            status: 500,
            message: message
          }
        end
      end

      result
    end

  end
end
