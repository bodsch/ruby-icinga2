
# frozen_string_literal: true
module Icinga2

  # namespace for network handling
  module Network

    # static function for GET Requests
    #
    # @param [Hash] params
    # @option params [String] host
    # @option params [String] url
    # @option params [String] headers
    # @option params [String] options
    # @option params [Hash] payload
    #
    #
    # @return [Hash]
    #
    def api_data( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = validate( params, required: true, var: 'url', type: String )
      headers = validate( params, required: true, var: 'headers', type: Hash )
      options = validate( params, required: true, var: 'options', type: Hash ).deep_symbolize_keys
      payload = validate( params, required: false, var: 'payload', type: Hash )

      rest_client = RestClient::Resource.new( URI.encode( url ), options )

      headers['X-HTTP-Method-Override'] = 'GET'
      method = 'GET'
      method = 'POST' if( payload )

      begin
        data = request( rest_client, method, headers, payload )

        data = JSON.parse( data ) if( data.is_a?(String) )
        data = data.deep_string_keys
        data = data.dig('results') if( data.is_a?(Hash) )

        return data
      rescue => e
        logger.error(e)
        logger.error(e.backtrace.join("\n"))

        return nil
      end
    end

    # static function for GET Requests without filters
    #
    # @param [Hash] params
    # @option params [String] host
    # @option params [String] url
    # @option params [String] headers
    # @option params [String] options
    # @option params [Hash] payload
    #
    #
    # @return [Hash]
    #
    def icinga_application_data( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = validate( params, required: true, var: 'url', type: String )
      headers = validate( params, required: true, var: 'headers', type: Hash )
      options = validate( params, required: true, var: 'options', type: Hash ).deep_symbolize_keys

      begin
        data = api_data( url: url, headers: headers, options: options )
        data = data.first if( data.is_a?(Array) )

        return data.dig('status') unless( data.nil? )
      rescue => e
        logger.error(e)
        logger.error(e.backtrace.join("\n"))

        return nil
      end

    end

    # static function for POST Requests
    #
    # @param [Hash] params
    # @option params [String] url
    # @option params [String] headers
    # @option params [String] options
    # @option params [Hash] payload
    #
    #
    # @return [Hash]
    #
    def post( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = validate( params, required: true, var: 'url', type: String )
      headers = validate( params, required: true, var: 'headers', type: Hash )
      options = validate( params, required: true, var: 'options', type: Hash ).deep_symbolize_keys
      payload = validate( params, required: false, var: 'payload', type: Hash )

      rest_client = RestClient::Resource.new( URI.encode( url ), options )

      headers['X-HTTP-Method-Override'] = 'POST'

      begin
        data = request( rest_client, 'POST', headers, payload )
        data = JSON.parse( data ) if( data.is_a?(String) )
        data = data.deep_string_keys
        data = data.dig('results') if( data.is_a?(Hash) )

        if( data.count == 0 )
          code   = 404
          name   = nil
          status = 'Object not found.'
        elsif( data.count == 1 )
          data   = data.first
          code   = data.dig('code').to_i
          name   = data.dig('name')
          status = data.dig('status')
        else
          code = data.max_by{|k| k['code'] }.dig('code')
          status = data.map do |hash|
            hash['status']
          end
        end

        return { 'code' => code, 'name' => name, 'status' => status }
      rescue => e
        logger.error(e)
        logger.error(e.backtrace.join("\n"))

        puts e
        puts e.backtrace.join("\n")

        return nil
      end
    end

    # static function for PUT Requests
    #
    # @param [Hash] params
    # @option params [String] host
    # @option params [String] url
    # @option params [String] headers
    # @option params [String] options
    # @option params [Hash] payload
    #
    #
    # @return [Hash]
    #
    def put( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = validate( params, required: true, var: 'url', type: String )
      headers = validate( params, required: true, var: 'headers', type: Hash )
      options = validate( params, required: true, var: 'options', type: Hash ).deep_symbolize_keys
      payload = validate( params, required: false, var: 'payload', type: Hash )

      rest_client = RestClient::Resource.new( URI.encode( url ), options )

      headers['X-HTTP-Method-Override'] = 'PUT'

      begin
        data = request( rest_client, 'PUT', headers, payload )
        data = JSON.parse( data ) if( data.is_a?(String) )
        data = data.deep_string_keys

        if( data.is_a?(Hash) )
          results = data.dig('results')
          results = results.first if( results.is_a?(Array) )
        else
          results = data
        end

        return { 'code' => results.dig('code').to_i, 'name' => results.dig('name'), 'status' => results.dig('status') } unless( results.nil? )
      rescue => e
        logger.error(e)
        logger.error(e.backtrace.join("\n"))

        return nil
      end
    end

    # static function for DELETE Requests
    #
    # @param [Hash] params
    # @option params [String] url
    # @option params [String] headers
    # @option params [String] options
    #
    #
    # @return [Hash]
    #
    def delete( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = validate( params, required: true, var: 'url', type: String )
      headers = validate( params, required: true, var: 'headers', type: Hash )
      options = validate( params, required: true, var: 'options', type: Hash ).deep_symbolize_keys

      rest_client = RestClient::Resource.new( URI.encode( url ), options )

      headers['X-HTTP-Method-Override'] = 'DELETE'

      begin
        data = request( rest_client, 'DELETE', headers )

        data = JSON.parse( data ) if( data.is_a?(String) )
        data = data.deep_string_keys

        if( data.is_a?(Hash) )
          results = data.dig('results')
          results = results.first if( results.is_a?(Array) )
        else
          results = data
        end

        return { 'code' => results.dig('code').to_i, 'name' => results.dig('name'), 'status' => results.dig('status') } unless( results.nil? )
      rescue => e
        logger.error(e)
        logger.error(e.backtrace.join("\n"))

        return nil
      end
    end

    # static function for GET Requests
    #
    # @param [Hash] params
    # @option params [String] url
    # @option params [String] headers
    # @option params [String] options
    #
    #
    # @return [Hash]
    #
    def get(params)

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      url     = validate( params, required: true, var: 'url', type: String )
      headers = validate( params, required: true, var: 'headers', type: Hash )
      options = validate( params, required: true, var: 'options', type: Hash ).deep_symbolize_keys

      rest_client = RestClient::Resource.new( URI.encode( url ), options )

      begin
        data = request( rest_client, 'GET', headers )

#         puts "data: #{data}"

        begin
          data = JSON.parse( data ) if( data.is_a?(String) )
          data = data.deep_string_keys
          data['code'] = 200
        rescue
          data
        end

        return data
      rescue => e
        logger.error(e)
        logger.error(e.backtrace.join("\n"))

        return nil
      end
    end

    private
    #
    # internal functionfor the Rest-Client Request
    #
    def request( client, method, headers, data = {} )

      logger.debug( "request( #{client.to_s}, #{method}, #{headers}, #{data} )" )

      raise ArgumentError.new('client must be an RestClient::Resource') unless( client.is_a?(RestClient::Resource) )
      raise ArgumentError.new('method must be an \'GET\', \'POST\', \'PUT\' or \'DELETE\'') unless( %w[GET POST PUT DELETE].include?(method) )
      raise ArgumentError.new(format('data must be an Hash (%s)', data.class.to_s)) unless( data.nil? || data.is_a?(Hash) )

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
          client.put( data.to_json, headers ) do |response, req, _result|

            @req           = req
            @response_body = response.body
            @response_code = response.code.to_i

            case response.code
            when 200
              return @response_body
            when 400
              raise RestClient::BadRequest
            when 404
              raise RestClient::NotFound
            when 500
              raise RestClient::InternalServerError
            else
              response.return
            end
          end

        when 'DELETE'
          response = client.delete( @headers )
        else
          return false
        end

        response_body    = response.body
        response_headers = response.headers

        begin
          return JSON.parse( response_body ) if( response_body.is_a?(String) )
        rescue
          return response_body
        end

      rescue RestClient::BadRequest

        response_body = JSON.parse(response_body) if response_body.is_a?(String)

        return { 'results' => [{ 'code' => 400, 'status' => response_body.nil? ? 'Bad Request' : response_body }] }

      rescue RestClient::Unauthorized

        return { 'results' => [{ 'code'  => 401, 'status' => format('Not authorized to connect \'%s\' - wrong username or password?', @icinga_api_url_base) }] }

      rescue RestClient::NotFound

        return { 'results' => [{ 'code' => 404, 'status' => 'Object not Found' }] }

      rescue RestClient::InternalServerError => error

        response_body = JSON.parse(@response_body) if @response_body.is_a?(String)

#         begin
#         puts '-------------------------------------'
#         puts response
#         puts response.class.to_s
#
#         puts response.code.to_i
#         puts response_body
#         puts response_body.class.to_s
#         puts '-------------------------------------'
#         rescue
#
#         end

        return { 'results' => [{ 'code' => 500, 'status' => error }] } if( response_body.nil? )

        results = response_body.dig('results')
        results = results.first if( results.is_a?(Array) )
        status  = results.dig('status')
        errors  = results.dig('errors')
        errors  = errors.first if( errors.is_a?(Array) )
        errors  = errors.sub(/ \'.*\'/,'')

        return { 'results' => [{ 'code' => 500, 'status' => format('%s (%s)', status, errors).delete('.') }] }

      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e

        # TODO
        # ist hier ein raise sinnvoll?
        raise format( "Maximum retries (%d) against '%s' reached. Giving up ...", max_retries, @icinga_api_url_base ) if( retried >= max_retries )

        retried += 1
        warn(format("Cannot execute request against '%s': '%s' (retry %d / %d)", @icinga_api_url_base, e, retried, max_retries))
        sleep(3)
        retry

      rescue RestClient::ExceptionWithResponse => e

        response = e.response
        response_body = response.body
        response_code = response.code

        if( response_body =~ /{(.*)}{(.*)}/ )
          parts     = response_body.match( /^{(?<regular>(.+))}{(.*)}/ )
          response_body = parts['regular'].to_s.strip
          response_body = format('{%s}', response_body )
        end

        begin
          response_body = JSON.parse(response_body) if response_body.is_a?(String)
          code   = response.code.to_i
          status = response_body.dig('status')

          result = { 'results' => [{ 'code' => code, 'status' => status }] }

        rescue => error
          puts(e)
          puts(e.backtrace.join("\n"))
        end

      rescue RestClient::ExceptionWithResponse => e

        @logger.error( "Error: #{__method__} #{method_type.upcase} on #{endpoint} error: '#{e}'" )
        @logger.error( data )
#         @logger.error( @headers )
#         @logger.error( JSON.pretty_generate( response_headers ) )

        return { 'results' => [{ 'code' => 500, 'status' => e }] }
      end

    end


  end
end
