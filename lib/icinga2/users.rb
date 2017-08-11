
# frozen_string_literal: true

module Icinga2

  # namespace for User handling
  module Users

    # add a user
    #
    # @param [Hash] params
    # @option params [String] :name user to create
    # @option params [String] :display_name the displayed name
    # @option params [String] :email ('') the user email
    # @option params [String] :pager ('') optional a pager
    # @option params [Bool] :enable_notifications (false) enable notifications for this user
    # @option params [Array] :groups ([]) a hash with groups
    #
    # @example
    #   @icinga.add_user(name: 'foo', display_name: 'FOO', email: 'foo@bar.com', pager: '0000', groups: ['icingaadmins'])
    #
    # @return [Hash] result
    #
    def add_user( params = {} )

      name          = params.dig(:name)
      display_name  = params.dig(:display_name)
      email         = params.dig(:email)
      pager         = params.dig(:pager)
      notifications = params.dig(:enable_notifications) || false
      groups        = params.dig(:groups) || []

      if( name.nil? )
        {
          status: 404,
          message: 'missing user name'
        }
      end

      unless( groups.is_a?( Array ) )
        {
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

        {
          status: 404,
          message: "these groups are not exists: #{groups}",
          data: params
        }
      end

      Network.put(
        url: format( '%s/objects/users/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # delete a user
    #
    # @param [Hash] params
    # @option params [String] :name user to delete
    #
    # @example
    #   @icinga.delete_user(name: 'foo')
    #
    # @return [Hash] result
    #
    def delete_user( params = {} )

      name = params.dig(:name)

      if( name.nil? )
        return {
          status: 404,
          message: 'missing user name'
        }
      end

      Network.delete(
        url: format( '%s/objects/users/%s?cascade=1', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options
      )
    end

    # returns all users
    #
    # @param [Hash] params
    # @option params [String] :name ('') optional for a single user
    #
    # @example to get all users
    #    @icinga.users
    #
    # @example to get one user
    #    @icinga.users(name: 'icingaadmin')
    #
    # @return [Hash] returns a hash with all users
    #
    def users( params = {} )

      name = params.dig(:name)

      url =
      if( name.nil? )
        format( '%s/objects/users'   , @icinga_api_url_base )
      else
        format( '%s/objects/users/%s', @icinga_api_url_base, name )
      end

      data = Network.api_data(
        url: url,
        headers: @headers,
        options: @options
      )

      return data.dig('results') if( data.dig(:status).nil? )

      nil
    end

    # returns true if the user exists
    #
    # @param [String] name the name of the user
    #
    # @example
    #    @icinga.exists_user?('icingaadmin')
    #
    # @return [Bool] returns true if the user exists
    def exists_user?( name )

      result = users( name: name )
      result = JSON.parse( result ) if  result.is_a?( String )

      return true if  !result.nil? && result.is_a?(Array)

      false
    end

  end
end
