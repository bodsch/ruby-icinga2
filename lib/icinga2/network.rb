
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
    def api_data( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload)

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )

      rest_client = RestClient::Resource.new( URI.encode( url ), options )

      max_retries = 10
      retried     = 0

      if( payload )
        raise ArgumentError.new('only Hash for payload are allowed') unless( payload.is_a?(Hash) )
        headers['X-HTTP-Method-Override'] = 'GET'
        method = 'POST'
      else
        method = 'GET'
      end

      begin
        data = request( rest_client, method, headers, options, payload )

# logger.debug(data.class.to_s)
# logger.debug(data)

        data = JSON.parse( data ) if( data.is_a?(String) )
        data = data.deep_string_keys

# logger.debug(JSON.pretty_generate data)

        if( data.is_a?(Hash) )
          results = data.dig('results')
#           results = results.first if( results.is_a?(Array) )
        else
          results = data
        end

# logger.debug(JSON.pretty_generate results)
# logger.debug('-----')
        return results # { status: results.dig('code').to_i, name: results.dig('name'), message: results.dig('status') } unless( results.nil? )

      rescue => e

        logger.error(e)
        logger.error( e.backtrace.join("\n") )
      end



#      exit 1

#      begin
#        if payload
#          headers['X-HTTP-Method-Override'] = 'GET'
#          payload = JSON.generate(payload)
#          res = rest_client.post(payload, headers)
#        else
#          res = rest_client.get(headers)
#        end
#
#
#      rescue RestClient::Unauthorized => e
#
#        return {
#          status: 401,
#          message: 'unauthorized'
#        }
#
#      rescue RestClient::NotFound => e
#
#        message = format( 'not found (request %s)', url )
##         $stderr.puts( message )
#
#        return {
#          status: 404,
#          message: message
#        }
#
#      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
#
#        if( retried < max_retries )
#          retried += 1
#          $stderr.puts(format("Cannot execute request against '%s': '%s' (retry %d / %d)", url, e, retried, max_retries))
#          sleep(2)
#          retry
#        else
#
#          message = format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url )
##           $stderr.puts( message )
#          raise message
#
#          return {
#            status: 500,
#            message: message
#          }
#        end
#      end
#
#      body = res.body
#      JSON.parse(body)
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
    def icinga_application_data( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )

      begin

        data = api_data( url: url, headers: headers, options: options )
        data = data.first if( data.is_a?(Array) )

        return data.dig('status') unless( data.nil? )

      rescue => e

        logger.error(e)

        return nil
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
    def post( params )

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

      rest_client = RestClient::Resource.new( URI.encode( url ), options )
      headers['X-HTTP-Method-Override'] = 'POST'

      begin
        data = request( rest_client, 'POST', headers, options, payload )

# logger.debug(data.class.to_s)
# logger.debug(data)

        data = JSON.parse( data ) if( data.is_a?(String) )
        data = data.deep_string_keys

        if( data.is_a?(Hash) )
          results = data.dig('results').first
        else
          results = data
        end

        return { status: results.dig('code').to_i, name: results.dig('name'), message: results.dig('status') } unless( results.nil? )

      rescue => e

        logger.error(e)
        logger.error( e.backtrace.join("\n") )
      end


#      max_retries = 30
#      retried     = 0
#      result      = {}
#
#      headers['X-HTTP-Method-Override'] = 'POST'
#
#      rest_client = RestClient::Resource.new(
#        URI.encode( url ),
#        options
#      )
#
#      begin
#
#        data = rest_client.post(
#          JSON.generate( payload ),
#          headers
#        )
#
#        data    = JSON.parse( data )
#        results = data.dig('results').first
#
#        return { status: results.dig('code').to_i, name: results.dig('name'), message: results.dig('status') } unless( results.nil? )
#
#      rescue RestClient::ExceptionWithResponse => e
#
#        error  = e.response ? e.response : nil
#        error = JSON.parse( error ) if  error.is_a?( String )
#
#        results = error.dig( 'results' )
#
#        if( !results.nil? )
#
##           result = result.first
#
#          return {
#            status: results.dig('code').to_i,
#            name: results.dig('name'),
#            message: results.dig('status'),
#            error: results.dig('errors')
#          }
#        else
#          return {
#            status: error.dig( 'error' ).to_i,
#            message: error.dig( 'status' )
#          }
#        end
#
#      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
#
#        if( retried < max_retries )
#          retried += 1
#          $stderr.puts(format("Cannot execute request against '%s': '%s' (retry %d / %d)", url, e, retried, max_retries))
#          sleep(2)
#          retry
#        else
#
#          message = format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url )
##           $stderr.puts( message )
#          raise message
#
#          return {
#            status: 500,
#            message: message
#          }
#        end
#      end
#
#      result
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
    def put( params )

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

      rest_client = RestClient::Resource.new( URI.encode( url ), options )
      headers['X-HTTP-Method-Override'] = 'PUT'

      begin

        data = request( rest_client, 'PUT', headers, options, payload )
        data = JSON.parse( data ) if( data.is_a?(String) )
        data = data.deep_string_keys

# logger.debug( JSON.pretty_generate( data ) )
# logger.debug(data.class.to_s)

        if( data.is_a?(Hash) )
          results = data.dig('results')
          results = results.first if( results.is_a?(Array) )
        else
          results = data
        end

        return { status: results.dig('code').to_i, name: results.dig('name'), message: results.dig('status') } unless( results.nil? )

      rescue => e

        logger.error(e)
        logger.error( e.backtrace.join("\n") )
      end









#       max_retries = 30
#       retried     = 0
#       result      = {}
#
#       headers['X-HTTP-Method-Override'] = 'PUT'
#
#       rest_client = RestClient::Resource.new(
#         URI.encode( url ),
#         options
#       )
#
#       begin
#         data = rest_client.put(
#           JSON.generate( payload ),
#           headers
#         )
#         data    = JSON.parse( data )
#         results = data.dig('results').first
#
#         return { status: results.dig('code').to_i, name: results.dig('name'), message: results.dig('status') } unless( results.nil? )
#
#       rescue RestClient::ExceptionWithResponse => e
#
#         error  = e.response ? e.response : nil
#         error = JSON.parse( error ) if  error.is_a?( String )
#
#         results = error.dig('results')
#
#         return { status: error.dig('error').to_i, message: error.dig('status'), error: results } if( results.nil? )
#
#         if( results.is_a?( Hash ) && results.count != 0 )
# #          result = result.first
#           return {
#             status: results.dig('code').to_i,
#             name: results.dig('name'),
#             message: results.dig('status'),
#             error: results
#           }
#         else
#           return {
#             status: results.first.dig('code').to_i,
#             message: format('%s (possible, object already exists)', results.first.dig('status') ),
#             error: results
#           }
#         end
#
#       rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
#
#         if( retried < max_retries )
#           retried += 1
#           $stderr.puts(format("Cannot execute request against '%s': '%s' (retry %d / %d)", url, e, retried, max_retries))
#           sleep(2)
#           retry
#         else
#
#           message = format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url )
# #          $stderr.puts( message )
#           raise message
#
#           return {
#             status: 500,
#             message: message
#           }
#         end
#       end
#
#       result
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
    def delete( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)

      raise ArgumentError.new('Missing url') if( url.nil? )
      raise ArgumentError.new('Missing headers') if( headers.nil? )
      raise ArgumentError.new('Missing options') if( options.nil? )

      rest_client = RestClient::Resource.new( URI.encode( url ), options )
      headers['X-HTTP-Method-Override'] = 'DELETE'

      begin
        data = request( rest_client, 'DELETE', headers, options )

        data = JSON.parse( data ) if( data.is_a?(String) )
        data = data.deep_string_keys

# logger.debug( JSON.pretty_generate( data ) )
# logger.debug(data.class.to_s)

        if( data.is_a?(Hash) )
          results = data.dig('results')
          results = results.first if( results.is_a?(Array) )
        else
          results = data
        end

        return { status: results.dig('code').to_i, name: results.dig('name'), message: results.dig('status') } unless( results.nil? )

      rescue => e
        logger.error(e)
        logger.error( e.backtrace.join("\n") )
      end






#       max_retries = 3
#       retried     = 0
#
#       headers['X-HTTP-Method-Override'] = 'DELETE'
#
#       result  = {}
#
#       rest_client = RestClient::Resource.new(
#         URI.encode( url ),
#         options
#       )
#
#       begin
#         data     = rest_client.get( headers )
#
#         if( data )
#
#           data    = JSON.parse( data )
#           results = data.dig('results').first
#
#           return { status: results.dig('code').to_i, name: results.dig('name'), message: results.dig('status') } unless( results.nil? )
#         end
#
#       rescue RestClient::ExceptionWithResponse => e
#
#         error  = e.response ? e.response : nil
#
#         error = JSON.parse( error ) if  error.is_a?( String )
#
#         results = error.dig('results')
#
#         if( results.nil? )
#           return {
#             status: error.dig( 'error' ).to_i,
#             message: error.dig( 'status' )
#           }
#         else
#           return {
#             status: results.dig('code').to_i,
#             name: results.dig('name'),
#             message: results.dig('status')
#           }
#         end
#       rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
#
#         if( retried < max_retries )
#           retried += 1
#           $stderr.puts(format("Cannot execute request against '%s': '%s' (retry %d / %d)", url, e, retried, max_retries))
#           sleep(2)
#           retry
#         else
#
#           message = format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, url )
# #           $stderr.puts( message )
#           raise message
#
#           return {
#             status: 500,
#             message: message
#           }
#         end
#       end
#
#       result
    end



    def request( client, method, headers, options, data = {} )

      logger.debug( "request( #{client.to_s}, #{method}, #{headers}, #{options}, #{data} )" )

      raise ArgumentError.new('client must be an RestClient::Resource') unless( client.is_a?(RestClient::Resource) )
      raise ArgumentError.new('method must be an \'GET\', \'POST\', \'PUT\' or \'DELETE\'') unless( %w(GET POST PUT DELETE).include?(method) )

      unless( data.nil? )
        raise ArgumentError.new(format('data must be an Hash (%s)', data.class.to_s)) unless( data.is_a?(Hash) )
      end

      max_retries = 3
      retried     = 0

      begin

        case method.upcase
        when 'GET'
          response = client.get( headers )
        when 'POST'
          response = client.post( data.to_json, headers )
        when 'PATCH'
          response = client.patch( data, headers )
        when 'PUT'
          # response = @api_instance[endpoint].put( data, @headers )
          client.put( data.to_json, headers ) do |response, req, result|

            @req           = req
            @response_raw  = response
            @response_body = response.body
            @response_code = response.code.to_i

#             logger.debug('----------------------------')
#             logger.debug(@response_raw)
#             logger.debug(@response_body)
#             logger.debug(@response_code)
#             logger.debug('----------------------------')

            case response.code
            when 200
#               response_raw  = response
#               response_body = response.body
#               response_code = response.code.to_i
              response_body = JSON.parse(@response_body) if @response_body.is_a?(String)

#             logger.debug('----------------------------')
#             logger.debug(@response_body)
#             logger.debug('----------------------------')

            return @response_body
#               return {
#                 'status' => @response_code,
#                 'message' => response_body.dig('results').nil? ? 'Successful' : response_body.dig('results')
#               }
            when 400
#               response_raw  = response
#               response_body = response.body
#               response_code = response.code.to_i
              raise RestClient::BadRequest
            when 404

#               @req           = req
#               @response_raw  = response
#               @response_body = response.body
#               @response_code = response.code.to_i
              raise RestClient::NotFound
            when 500

              raise RestClient::InternalServerError
            else

#               logger.debug('----------------------------')
#               logger.debug(@response_raw)
#               logger.debug(@response_body)
#               logger.debug(@response_code)
#               logger.debug('----------------------------')

              response.return #!(@req, result)
            end
          end

        when 'DELETE'
          response = client.delete( @headers )
        else
          @logger.error( "Error: #{__method__} is not a valid request method." )
          return false
        end

        response_code    = response.code.to_i
        response_body    = response.body
        response_headers = response.headers

        response_body = JSON.parse( response_body )

        results = response_body.dig('results')
        results = results.first if( results.is_a?(Array) )

#         logger.debug(response_body)

        #response_body['results'] =|| []
        results['code'] = response_code

        return response_body

      rescue RestClient::BadRequest

        logger.debug('---------------------------')
        logger.error( response_body.class.to_s )
        response_body = JSON.parse(response_body) if response_body.is_a?(String)

        logger.error( response_body.class.to_s )
        logger.debug('---------------------------')

        return {
          'status' => 400,
          'message' => response_body.nil? ? 'Bad Request' : response_body
        }

      rescue RestClient::Unauthorized

        return {
          'status' => 401,
          'message' => format('Not authorized to connect \'%s\' - wrong username or password?', @icinga_api_url_base)
        }

      rescue RestClient::NotFound

        return {
          'results': [{
          'code' => 404,
          'status' => 'Object not Found'
          }]
        }

      rescue RestClient::InternalServerError
#               logger.debug('----------------------------')
#               logger.debug(@response_raw)
#               logger.debug(@response_body)
#               logger.debug(@response_code)
#               logger.debug('----------------------------')

        response_body = JSON.parse(@response_body) if @response_body.is_a?(String)

        results = response_body.dig('results')
        results = results.first if( results.is_a?(Array) )
        status  = results.dig('status').gsub('.','')
        errors  = results.dig('errors')
        errors  = errors.first if( errors.is_a?(Array) )
        errors  = errors.sub(/ \'.*\'/,'')

#         logger.debug(results.dig('status'))
#         logger.debug(errors)
#         logger.debug(errors.class.to_s)

        return {
          'results': [{
          'code' => 500,
          'status' => format('%s (%s)', status, errors)
          }]
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
          raise message

          return {
            status: 500,
            message: message
          }
        end

      rescue RestClient::ExceptionWithResponse => e

        @logger.error( "Error: #{__method__} #{method_type.upcase} on #{endpoint} error: '#{e}'" )
        @logger.error( data )
        @logger.error( @headers )
        @logger.error( JSON.pretty_generate( response_headers ) )

        return false

      end

    end


  end
end
