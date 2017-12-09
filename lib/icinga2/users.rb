
# frozen_string_literal: true

module Icinga2

  # namespace for User handling
  module Users

    # add a user
    #
    # @param [Hash] params
    # @option params [String] user_name  user to create
    # @option params [String] display_name ('') the displayed name
    # @option params [String] email ('') the user email
    # @option params [String] pager ('') optional a pager
    # @option params [Bool] enable_notifications (false) enable notifications for this user
    # @option params [Array] groups ([]) a hash with groups
    # @option params [String] period
    # @option params [Array] states
    # @option params [Array] types
    # @option params [Hash] vars
    #
    # @example
    #    param = {
    #      user_name: 'foo',
    #      display_name: 'FOO',
    #      email: 'foo@bar.com',
    #      pager: '0000',
    #      groups: ['icingaadmins']
    #    }
    #    @icinga.add_user(param)
    #
    # @return [Hash] result
    #    * code [Integer]
    #    * message [String]
    #    * data (optional)
    #
    def add_user( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing \'params\'') if( params.size.zero? )

      user_name = validate( params, required: true, var: 'user_name', type: String )
      display_name = validate( params, required: false, var: 'display_name', type: String )
      email = validate( params, required: false, var: 'email', type: String )
      pager = validate( params, required: false, var: 'pager', type: String )
      notifications = validate( params, required: false, var: 'enable_notifications', type: Boolean ) || false
      groups = validate( params, required: false, var: 'groups', type: Array ) || []
      period = validate( params, required: false, var: 'period', type: String )
      states = validate( params, required: false, var: 'states', type: Array )
      types = validate( params, required: false, var: 'types', type: Array )
      vars = validate( params, required: false, var: 'vars', type: Hash ) || {}

      group_validate = []

      groups.each do |g|
        group_validate << g if  exists_usergroup?( g ) == false
      end

      if( group_validate.count != 0 )
        return {
          'code' => 404,
          'message' => format('these groups are not exists: \'%s\'', group_validate.join(', ')),
          'data' => params
        }
      end

      payload = {
        attrs: {
          display_name: display_name,
          email: email,
          pager: pager,
          enable_notifications: notifications,
          groups: groups,
          period: period,
          states: states,
          types: types,
          vars: vars
        }
      }

      # remove all empty attrs
      payload.reject!{ |_k, v| v.nil? }
      payload[:attrs].reject!{ |_k, v| v.nil? }

      put(
        url: format( '%s/objects/users/%s', @icinga_api_url_base, user_name ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # delete a user
    #
    # @param [String] user_name user to delete
    #
    # @example
    #   @icinga.delete_user('foo')
    #
    # @return [Hash] result
    #
    def delete_user( user_name )

      raise ArgumentError.new(format('wrong type. \'user_name\' must be an String, given \'%s\'',user_name.class.to_s)) unless( user_name.is_a?(String) )
      raise ArgumentError.new('Missing user_name') if( user_name.size.zero? )

      delete(
        url: format( '%s/objects/users/%s?cascade=1', @icinga_api_url_base, user_name ),
        headers: @headers,
        options: @options
      )
    end

    # returns a named or all users
    #
    # @param [String] user_name ('') optional for a single user
    #
    # @example to get all users
    #    @icinga.users
    #
    # @example to get one user
    #    @icinga.users('icingaadmin')
    #
    # @return [Array]
    #
    def users( user_name = nil )

      url = format( '%s/objects/users'   , @icinga_api_url_base )
      url = format( '%s/objects/users/%s', @icinga_api_url_base, user_name ) unless( user_name.nil? )

      api_data(
        url: url,
        headers: @headers,
        options: @options
      )
    end

    # checks if the user exists
    #
    # @param [String] user_name the name of the user
    #
    # @example
    #    @icinga.exists_user?('icingaadmin')
    #
    # @return [Bool] returns true if the user exists
    #
    def exists_user?( user_name )

      raise ArgumentError.new(format('wrong type. \'user_name\' must be an String, given \'%s\'', user_name.class.to_s)) unless( user_name.is_a?(String) )
      raise ArgumentError.new('Missing \'user_name\'') if( user_name.size.zero? )

      result = users( user_name )
      result = JSON.parse( result ) if result.is_a?( String )
      result = result.first if( result.is_a?(Array) )

      return false if( result.is_a?(Hash) && result.dig('code') == 404 )

      true
    end

  end
end
