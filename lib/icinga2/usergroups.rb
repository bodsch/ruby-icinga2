
# frozen_string_literal: true

module Icinga2

  # namespace for usergroup handling
  module Usergroups

    # add a usergroup
    #
    # @param [Hash] params
    # @option params [String] user_group usergroup to create
    # @option params [String] display_name the displayed name
    #
    # @example
    #   @icinga.add_usergroup(user_group: 'foo', display_name: 'FOO')
    #
    # @return [Hash] result
    #
    def add_usergroup( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing \'params\'') if( params.size.zero? )

      user_group   = validate( params, required: true, var: 'user_group', type: String )
      display_name = validate( params, required: false, var: 'display_name', type: String )

      payload = {
        attrs: {
          display_name: display_name
        }
      }

      # remove all empty attrs
      payload.reject!{ |_k, v| v.nil? }
      payload[:attrs].reject!{ |_k, v| v.nil? }

      put(
        url: format( '%s/objects/usergroups/%s', @icinga_api_url_base, user_group ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # delete a usergroup
    #
    # @param [String] user_group usergroup to delete
    #
    # @example
    #   @icinga.delete_usergroup('foo')
    #
    # @return [Hash] result
    #
    def delete_usergroup( user_group )

      raise ArgumentError.new(format('wrong type. \'user_group\' must be an String, given \'%s\'', user_group.class.to_s)) unless( user_group.is_a?(String) )
      raise ArgumentError.new('missing \'user_group\'') if( user_group.size.zero? )

      delete(
        url: format( '%s/objects/usergroups/%s?cascade=1', @icinga_api_url_base, user_group ),
        headers: @headers,
        options: @options
      )
    end

    # returns all usersgroups
    #
    # @param [String] user_group (nil) optional for a single usergroup
    #
    # @example to get all users
    #    @icinga.usergroups
    #
    # @example to get one user
    #    @icinga.usergroups('icingaadmins')
    #
    # @return [Hash] returns a hash with all usergroups
    #
    def usergroups( user_group = nil )

      url = format( '%s/objects/usergroups'   , @icinga_api_url_base )
      url = format( '%s/objects/usergroups/%s', @icinga_api_url_base, user_group ) unless( user_group.nil? )

      api_data(
        url: url,
        headers: @headers,
        options: @options
      )
    end

    # returns true if the usergroup exists
    #
    # @param [String] user_group the name of the usergroups
    #
    # @example
    #    @icinga.exists_usergroup?('icingaadmins')
    #
    # @return [Bool] returns true if the usergroup exists
    #
    def exists_usergroup?( user_group )

      raise ArgumentError.new(format('wrong type. \'user_group\' must be an String, given \'%s\'', user_group.class.to_s)) unless( user_group.is_a?(String) )
      raise ArgumentError.new('Missing \'user_group\'') if( user_group.size.zero? )

      result = usergroups( user_group )
      result = JSON.parse( result ) if result.is_a?( String )
      result = result.first if( result.is_a?(Array) )

      return false if( result.is_a?(Hash) && result.dig('code') == 404 )

      true
    end

  end
end
