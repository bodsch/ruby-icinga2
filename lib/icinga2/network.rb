
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
    def self.api_data( params = {} )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload) || {}

#       puts params

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

        {
          status: 401,
          message: 'unauthorized'
        }

      rescue RestClient::NotFound => e

        message = format( 'not found (request %s)', url )

        $stderr.puts( message )

        {
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
          $stderr.puts( message )

          {
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
    def self.application_data( params = {} )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)

      data    = Network.api_data( url: url, headers: headers, options: options )

      if( data.dig(:status).nil? )
        results = data.dig('results')
        return results.first.dig('status') unless( results.nil? )
      end
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
    def self.post( params = {} )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload)
      max_retries   = 30
      times_retried = 0

      headers['X-HTTP-Method-Override'] = 'POST'

      result  = {}

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

        unless( results.nil? )

          result = {
            status: results.dig('code').to_i,
            name: results.dig('name'),
            message: results.dig('status')
          }

        end

      rescue RestClient::ExceptionWithResponse => e

        error  = e.response ? e.response : nil
        error = JSON.parse( error ) if  error.is_a?( String )

        results = error.dig( 'results' )

        if( !results.nil? )

          result = result.first

          result = {
            status: results.dig('code').to_i,
            name: results.dig('name'),
            message: results.dig('status'),
            error: results.dig('errors')
          }
        else
          result = {
            status: error.dig( 'error' ).to_i,
            message: error.dig( 'status' )
          }
        end

      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e

        if( times_retried < max_retries )

          times_retried += 1
          $stderr.puts(format( 'Cannot execute request %s', url ))
          $stderr.puts(format( '   cause: %s', e ))
          $stderr.puts(format( '   retry %d / %d', times_retried, max_retries ))

          sleep( 4 )
          retry
        else
          $stderr.puts( 'Exiting request ...' )

          {
            status: 500,
            message: format( 'Errno::ECONNREFUSED for request: %s', url )
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
    def self.put( params = {} )

      host    = params.dig(:host)
      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload)
      max_retries   = 30
      times_retried = 0

      headers['X-HTTP-Method-Override'] = 'PUT'

      result  = {}

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

        unless( results.nil? )

          result = {
            status: results.dig('code').to_i,
            name: results.dig('name'),
            message: results.dig('status')
          }

        end

      rescue RestClient::ExceptionWithResponse => e

        error  = e.response ? e.response : nil
        error = JSON.parse( error ) if  error.is_a?( String )

        results = error.dig( 'results' )

        if( !results.nil? )
          if( result.is_a?( Hash ) && result.count != 0 )

            result = result.first
            result = {
              status: results.dig('code').to_i,
              name: results.dig('name'),
              message: results.dig('status'),
              error: results.dig('errors')
            }
          else
            result = {
              status: 204,
              name: host,
              message: 'unknown result'
            }
          end
        else
          result = {
            status: error.dig( 'error' ).to_i,
            message: error.dig( 'status' )
          }
        end

      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e

        if( times_retried < max_retries )

          times_retried += 1
          $stderr.puts(format( 'Cannot execute request %s', url ))
          $stderr.puts(format( '   cause: %s', e ))
          $stderr.puts(format( '   retry %d / %d', times_retried, max_retries ))

          sleep( 4 )
          retry
        else
          $stderr.puts( 'Exiting request ...' )

          {
            status: 500,
            message: format( 'Errno::ECONNREFUSED for request: %s', url )
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
    def self.delete( params = {} )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      max_retries   = 3
      times_retried = 0

      headers['X-HTTP-Method-Override'] = 'DELETE'

      result  = {}

      rest_client = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin
        data     = rest_client.get( headers )

        if( data )

          data    = JSON.parse( data ) #.body )
          results = data.dig('results').first

          unless( results.nil? )

            result = {
              status: results.dig('code').to_i,
              name: results.dig('name'),
              message: results.dig('status')
            }

          end
        end

      rescue RestClient::ExceptionWithResponse => e

        error  = e.response ? e.response : nil

        error = JSON.parse( error ) if  error.is_a?( String )

        results = error.dig('results')

        result = if( !results.nil? )

          {
            status: results.dig('code').to_i,
            name: results.dig('name'),
            message: results.dig('status')
          }

        else

          {
            status: error.dig( 'error' ).to_i,
#            :name        => results.dig('name'),
            message: error.dig( 'status' )
          }

                 end
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e

        if( times_retried < max_retries )

          times_retried += 1
          $stderr.puts(format( 'Cannot execute request %s', url ))
          $stderr.puts(format( '   cause: %s', e ))
          $stderr.puts(format( '   retry %d / %d', times_retried, max_retries ))

          sleep( 4 )
          retry
        else
          $stderr.puts( 'Exiting request ...' )

          {
            status: 500,
            message: format( 'Errno::ECONNREFUSED for request: %s', url )
          }
        end
      end

      result
    end

  end

end
