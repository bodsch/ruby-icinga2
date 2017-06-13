# frozen_string_literal: true
module Icinga2

  module Network

    def self.get( params = {} )

      host    = params.dig(:host)
      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload) || {}
      result  = {}

      return get2( params ) if  payload.count >= 1 


      headers.delete( 'X-HTTP-Method-Override' )

      result  = {}

      restClient = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin

        data     = restClient.get( headers )
        results  = JSON.parse( data.body )
        results  = results.dig('results')

        result[:status] = 200
        result[:data] ||={}

        results.each do |r|

#          puts JSON.pretty_generate r
#          name = r.dig('name')
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

      rescue RestClient::ExceptionWithResponse => e

        error  = e.response ? e.response : nil

        error  = JSON.parse( error )

        result = {
          status: error['error'].to_i,
          name: host,
          message: error['status']
        }
      rescue Errno::ECONNREFUSED => e

        $stderr.puts 'Server refusing connection; retrying in 5s...'

      end

      result

    end


    def self.get2( params = {} )

      host    = params.dig(:host)
      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload) || {}
      result  = {}

      headers['X-HTTP-Method-Override'] = 'GET'

      restClient = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin

        response = restClient.post(
          JSON.generate( payload ),
          headers
        )

        responseCode = response.code
        responseBody = response.body

        node         = {}

        data    = JSON.parse( responseBody )

        results = data.dig('results')

        unless( results.nil? )

          results.each do |r|

            node[r.dig('name')] = r
          end

          result = {
            status: responseCode,
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
      rescue Errno::ECONNREFUSED => e

        $stderr.puts 'Server refusing connection; retrying in 5s...'

      end

      result

    end



    def self.post( params = {} )

      host    = params.dig(:host)
      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload)

      headers['X-HTTP-Method-Override'] = 'POST'

      result  = {}

      restClient = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin

        data = restClient.post(
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

        $stderr.puts( JSON.pretty_generate( error ) )

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

      rescue Errno::ECONNREFUSED => e

        $stderr.puts 'Server refusing connection; retrying in 5s...'

      rescue => e

        $stderr.puts e

      end

      result



    end


    def self.put( params = {} )

      host    = params.dig(:host)
      url     = params.dig(:url)
      headers = params.dig(:headers)
      options = params.dig(:options)
      payload = params.dig(:payload)

      headers['X-HTTP-Method-Override'] = 'PUT'

      result  = {}

      restClient = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin

        data = restClient.put(
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

      rescue Errno::ECONNREFUSED => e

        $stderr.puts 'Server refusing connection; retrying in 5s...'

      end

      result

    end


    def self.delete( params = {} )

      host    = params.dig(:host)    || nil
      url     = params.dig(:url)     || nil
      headers = params.dig(:headers) || nil
      options = params.dig(:options) || nil
      payload = params.dig(:payload) || nil

      headers['X-HTTP-Method-Override'] = 'DELETE'

      result  = {}

      restClient = RestClient::Resource.new(
        URI.encode( url ),
        options
      )

      begin
        data     = restClient.get( headers )

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
      rescue Errno::ECONNREFUSED => e

        $stderr.puts 'Server refusing connection; retrying in 5s...'

      end

      result

    end

  end
end


