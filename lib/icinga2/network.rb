
# frozen_string_literal: true
module Icinga2

  # namespace for network handling
  module NetworkNG

    def self.api_data( params = {} )

      host    = params.dig(:host)
      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload) || {}

      rest_client = RestClient::Resource.new( URI.encode( url ), options )

      max_retries = 30
      retried     = 0

      begin
        if payload
          headers["X-HTTP-Method-Override"] = "GET"
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

      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e

        if (retried < max_retries)
          retried += 1
          $stderr.puts(format("Cannot execute request against '%s': '%s' (retry %d / %d)", api_url, e, retried, max_retries))
          sleep(2)
          retry
        else
          $stderr.puts("Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, api_url)

          return {
            status: 500,
            message: format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url )
          }

        end
      end

      body = res.body
      data = JSON.parse(body)

      return data
    end


    def self.application_data( params = {} )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)

#       puts params

      data    = NetworkNG.api_data( url: url, headers: headers, options: options )

      status  = data.dig(:status)

      if( status.nil? )

        results = data.dig('results')

        unless( results.nil? )

          return results.first.dig('status')
        end
      end

      return nil

#       if not data or not data.has_key?('results') or data['results'].empty? or not data['results'][0].has_key?('status')
#         return nil
#       end
#
#       return data['results'][0]['status'] #there's only one row
    end

  end

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
    def self.get( params = {} )

      host    = params.dig(:host)
      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload) || {}
      result  = {}
      max_retries   = 30
      times_retried = 0

      return get_with_payload( params ) if  payload.count >= 1

      headers.delete( 'X-HTTP-Method-Override' )

      result  = {}

      rest_client = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin

        data     = rest_client.get( headers )
        results  = JSON.parse( data.body )
        results  = results.dig('results')

        result[:status] = 200
        result[:data] ||={}

        results.each do |r|
          attrs = r.dig('attrs')
          if( !attrs.nil? )
            result[:data][attrs['name']] = {
              name: attrs['name'],
              display_name: attrs['display_name'],
              type: attrs['type']
            }
          else
            result = r
          end

        end
      rescue RestClient::Unauthorized => e

        result = {
          status: 401,
          name: host,
          message: 'unauthorized'
        }

      rescue RestClient::ExceptionWithResponse => e

        error  = e.response ? e.response : nil
        error  = JSON.parse( error )

        result = {
          status: error['error'].to_i,
          name: host,
          message: error['status']
        }
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e

        if( times_retried < max_retries )

          times_retried += 1
          $stderr.puts(format( 'Cannot execute request %s', url ))
          $stderr.puts(format( '   cause: %s', e ))
          $stderr.puts(format( '   retry %d / %d', times_retried, max_retries ))

          sleep( 4 )
          retry
        else
          $stderr.puts(format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url ))

          return {
            status: 500,
            message: format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url )
          }
        end
      end

      result
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
    def self.get_raw( params = {} )

      host    = params.dig(:host)
      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload) || {}
      result  = {}
      max_retries   = 30
      times_retried = 0

      return get_with_payload( params ) if  payload.count >= 1

      headers.delete( 'X-HTTP-Method-Override' )

      result  = {}

      rest_client = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin

        data     = rest_client.get( headers )
        results  = JSON.parse( data.body )
        results  = results.dig('results')

        result[:status] = 200
        result[:data] ||={}

        results.each do |r|

          r.reject! { |x| x == 'perfdata' }
          result[:data][r.dig('name')] = r.dig('status')
        end

      rescue RestClient::ExceptionWithResponse => e

        error  = e.response ? e.response : nil
        error  = JSON.parse( error )

        result = {
          status: error['error'].to_i,
          name: host,
          message: error['status']
        }
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e

        if( times_retried < max_retries )

          times_retried += 1
          $stderr.puts(format( 'Cannot execute request %s', url ))
          $stderr.puts(format( '   cause: %s', e ))
          $stderr.puts(format( '   retry %d / %d', times_retried, max_retries ))

          sleep( 4 )
          retry
        else
          $stderr.puts(format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url ))

          return {
            status: 500,
            message: format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url )
          }
        end
      end

      result
    end


    # static function for GET Requests with payload
    # internal we use here an POST Request and overwrite a http header
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
    def self.get_with_payload( params = {} )

      host    = params.dig(:host)
      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload) || {}
      result  = {}
      max_retries   = 30
      times_retried = 0

      headers['X-HTTP-Method-Override'] = 'GET'

      rest_client = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin

        response = rest_client.post(
          JSON.generate( payload ),
          headers
        )

        response_code = response.code
        response_body = response.body
        node         = {}

        data    = JSON.parse( response_body )
        results = data.dig('results')

        unless( results.nil? )

          results.each do |r|
            node[r.dig('name')] = r
          end

          result = {
            status: response_code,
            nodes: node
          }
        end

      rescue RestClient::ExceptionWithResponse => e

        error  = e.response ? e.response : nil
        error  = JSON.parse( error )

        result = {
          status: error['error'].to_i,
          name: host,
          message: error['status']
        }
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH  => e

        if( times_retried < max_retries )

          times_retried += 1
          $stderr.puts(format( 'Cannot execute request %s', url ))
          $stderr.puts(format( '   cause: %s', e ))
          $stderr.puts(format( '   retry %d / %d', times_retried, max_retries ))

          sleep( 4 )
          retry
        else
          $stderr.puts( 'Exiting request ...' )

          return {
            status: 500,
            message: format( 'Errno::ECONNREFUSED for request: %s', url )
          }
        end
      end

      result

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

          return {
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

          return {
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

          return {
            status: 500,
            message: format( 'Errno::ECONNREFUSED for request: %s', url )
          }
        end
      end

      result
    end

  end
end


