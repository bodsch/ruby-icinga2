
# frozen_string_literal: true
module Icinga2

  module Usergroups

    def addUsergroup( params = {} )

      name     = params.dig(:name)
      vars     = params.dig(:vars) || {}

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


    def deleteUsergroup( params = {} )

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


    def listUsergroups( params = {} )

      name = params.dig(:name)

      result = Network.get(         host: name,
        url: format( '%s/v1/objects/usergroups/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )

    end


    def existsUsergroup?( name )

      result = listUsergroups( name: name )

      result = JSON.parse( result ) if  result.is_a?( String ) 

      status = result.dig('status')

      return true if  !status.nil? && status == 200 

      false

    end


  end

end


