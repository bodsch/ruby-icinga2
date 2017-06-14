
# frozen_string_literal: true
module Icinga2

  module Servicegroups


    def add_servicegroup( params = {} )
      name = params.dig(:name)
      display_name = params.dig(:display_name)
      if( name.nil? )
        return {
          status: 404,
          message: 'missing servicegroup name'
        }
      end

      payload = { 'attrs' => { 'display_name' => display_name } }

      result = Network.put(         host: name,
        url: format( '%s/v1/objects/servicegroups/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options,
        payload: payload )

      JSON.pretty_generate( result )
    end


    def delete_servicegroup( params = {} )
      name = params.dig(:name)
      if( name.nil? )
        return {
          status: 404,
          message: 'missing servicegroup name'
        }
      end

      result = Network.delete(         host: name,
        url: format( '%s/v1/objects/servicegroups/%s?cascade=1', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )
    end


    def servicegroups( params = {} )
      name = params.dig(:name)
      result = Network.get(         host: name,
        url: format( '%s/v1/objects/servicegroups/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )
    end


    def exists_servicegroup?( name )
      result = servicegroups( name: name )
      result = JSON.parse( result ) if  result.is_a?( String )
      status = result.dig('status')
      return true if  !status.nil? && status == 200
      false
    end


  end

end
