
# frozen_string_literal: true
module Icinga2

  module Users

    def add_user( params = {} )

      name          = params.dig(:name)
      display_name   = params.dig(:display_name)
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
          'display_name'         => display_name,
          'email'                => email,
          'pager'                => pager,
          'enable_notifications' => notifications
        }
      }

      payload['attrs']['groups'] = groups unless  groups.empty?

      group_validate = []

      groups.each do |g|

        group_validate << g if  exists_usergroup?( g ) == false

      end

      if( group_validate.count != 0 )

        groups = group_validate.join(', ')

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


    def delete_user( params = {} )

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


    def users( params = {} )

      name = params.dig(:name)

      result = Network.get(         host: name,
        url: format( '%s/v1/objects/users/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )

    end


    def exists_user?( name )

      result = users( name: name )

      result = JSON.parse( result ) if  result.is_a?( String )

      status = result.dig('status')

      return true if  !status.nil? && status == 200

      false

    end


  end

end

