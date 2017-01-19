module Icinga

  module Network

    def self.get( params = {} )

      print "GET\n"

      host    = params.dig(:host)    || nil
      url     = params.dig(:url)     || nil
      headers = params.dig(:headers) || nil
      options = params.dig(:options) || nil

      headers.delete( 'X-HTTP-Method-Override' )

      result  = {}

      print url + "\n"

      restClient = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin

        data  = restClient.get( headers )
        results  = JSON.parse( data.body )
        results  = results.dig('results')

        result[:status] = 200
        result[:data] ||={}

        results.each do |r|

          attrs = r.dig('attrs')

          result[:data][attrs['name']] = {
            :name         => attrs['name'],
            :display_name => attrs['display_name'],
            :type         => attrs['type']
          }

        end

      rescue RestClient::ExceptionWithResponse => e

        puts e.inspect

        error  = e.response ? e.response : nil

        puts error

        error = JSON.parse( error )

        result = {
          :status      => error['error'].to_i,
          :name        => host,
          :message     => error['status']
        }
      rescue Errno::ECONNREFUSED => e

        puts e.inspect

        $stderr.puts "Server refusing connection; retrying in 5s..."

      end

      return result

    end


    def self.put( params = {} )

      print "PUT\n"

      host    = params.dig(:host)    || nil
      url     = params.dig(:url)     || nil
      headers = params.dig(:headers) || nil
      options = params.dig(:options) || nil
      payload = params.dig(:payload) || nil

      result  = {}

      print url + "\n"

      restClient = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin

        data = restClient.put(
          JSON.generate( payload ),
          headers
        )

        data   = JSON.parse( data )
        result = data.dig('results')

        puts( result )

        if( result != nil && result.is_a?( Array ) )

          result = result.first

          if( result != nil )

            status  = 200
            name    = host
            message = result.dig('status' )
          end
        else

          status  = 400
          name    = host
          message = 'no valid result'
        end


      rescue RestClient::ExceptionWithResponse => e

        error  = e.response ? e.response : nil

        puts error

        if( error.is_a?( String ) )
          error = JSON.parse( error )
        end

        results = error.dig( 'results')

        if( results != nil )

          result  = results.first # error['results'][0] ? error['results'][0] : error
          status  = result.dig( 'code' ).to_i
          message = result.dig( 'status' )
        else

          status  = error.dig( 'error' ).to_i
          message = error.dig( 'status' )
        end

        status      = status
        name        = host
        message     = message

      end

      result = {
        :status      => status,
        :name        => name,
        :message     => message
      }

      return result

    end


    def self.delete( params = {} )

      print "DELETE\n"

      host    = params.dig(:host)    || nil
      url     = params.dig(:url)     || nil
      headers = params.dig(:headers) || nil
      options = params.dig(:options) || nil
      payload = params.dig(:payload) || nil

      headers['X-HTTP-Method-Override'] = 'DELETE'

      result  = {}

      print url + "\n"

      restClient = RestClient::Resource.new(
        URI.encode( url ),
        options
      )


      begin
        data     = restClient.get( headers )

        data  = JSON.parse( data ) #.body )

        puts data

        results  = data.dig('results')

        if( result != nil )

          result = {
            :status       => 200,
            :name        => host,
            :message     => result['status']
          }

        end

      rescue RestClient::ExceptionWithResponse => e

        error  = e.response ? e.response : nil

        puts error

        if( error.is_a?( String ) )
          error = JSON.parse( error )
        end

        results = error.dig( 'results')

        if( results != nil )

          result  = results.first # error['results'][0] ? error['results'][0] : error
          status  = result.dig( 'code' ).to_i
          message = result.dig( 'status' )
        else

          status  = error.dig( 'error' ).to_i
          message = error.dig( 'status' )
        end

        status      = status
        name        = host
        message     = message

      end

      result = {
        :status      => status,
        :name        => name,
        :message     => message
      }

      return result

    end

  end
end


