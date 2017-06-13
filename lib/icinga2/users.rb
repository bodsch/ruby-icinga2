
# frozen_string_literal: true
module Icinga2

  module Users

    def addUser( params = {} )

      name          = params.dig(:name)
      displayName   = params.dig(:display_name)
      email         = params.dig(:email)
      pager         = params.dig(:pager)
      notifications = params.dig(:enable_notifications) || false
      groups        = params.dig(:groups) || []

      if( name.nil? )

        return {
          status: 404,
          message: 'missing user name'
        }
      end

      unless( groups.is_a?( Array ) )

        return {
          status: 404,
          message: 'groups must be an array',
          data: params
        }
      end

      payload = {
        'attrs' => {
          'display_name'         => displayName,
          'email'                => email,
          'pager'                => pager,
          'enable_notifications' => notifications
        }
      }

      payload['attrs']['groups'] = groups unless  groups.empty? 

      groupValidate = []

      groups.each do |g|

        groupValidate << g if  existsUsergroup?( g ) == false 

      end

      if( groupValidate.count != 0 )

        groups = groupValidate.join(', ')

        return {

          status: 404,
          message: "these groups are not exists: #{groups}",
          data: params
        }

      end

      result = Network.put(         host: name,
        url: format( '%s/v1/objects/users/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options,
        payload: payload )

      JSON.pretty_generate( result )

    end


    def deleteUser( params = {} )

      name = params.dig(:name)

      if( name.nil? )

        return {
          status: 404,
          message: 'missing user name'
        }
      end

      result = Network.delete(         host: name,
        url: format( '%s/v1/objects/users/%s?cascade=1', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )

    end


    def listUsers( params = {} )

      name = params.dig(:name)

      result = Network.get(         host: name,
        url: format( '%s/v1/objects/users/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )

    end


    def existsUser?( name )

      result = listUsers( name: name )

      result = JSON.parse( result ) if  result.is_a?( String ) 

      status = result.dig('status')

      return true if  !status.nil? && status == 200 

      false

    end


  end

end

