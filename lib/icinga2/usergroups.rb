
# frozen_string_literal: true
module Icinga2

  module Usergroups

    def add_usergroup( params = {} )

      name     = params.dig(:name)
      if( name.nil? )
        return {
          status: 404,
          message: 'missing usergroup name'
        }
      end

      payload = {
        'attrs' => {
          'display_name'         => name
        }
      }

      result = Network.put(         host: name,
        url: format( '%s/v1/objects/usergroups/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options,
        payload: payload )

      JSON.pretty_generate( result )

    end


    def delete_usergroup( params = {} )
      name = params.dig(:name)
      if( name.nil? )
        return {
          status: 404,
          message: 'missing usergroup name'
        }
      end
      result = Network.delete(         host: name,
        url: format( '%s/v1/objects/usergroups/%s?cascade=1', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options )
      JSON.pretty_generate( result )
    end


    def usergroups( params = {} )
      name = params.dig(:name)
      result = Network.get(         host: name,
        url: format( '%s/v1/objects/usergroups/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options )
      JSON.pretty_generate( result )
    end


    def exists_usergroup?( name )

      result = usergroups( name: name )
      result = JSON.parse( result ) if  result.is_a?( String )
      status = result.dig('status')
      return true if  !status.nil? && status == 200
      false
    end


  end

end


