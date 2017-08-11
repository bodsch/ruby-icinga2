
# frozen_string_literal: true

module Icinga2

  # namespace for usergroup handling
  module Usergroups

    # add a usergroup
    #
    # @param [Hash] params
    # @option params [String] :name usergroup to create
    # @option params [String] :display_name the displayed name
    #
    # @example
    #   @icinga.add_usergroup(name: 'foo', display_name: 'FOO')
    #
    # @return [Hash] result
    #
    def add_usergroup( params = {} )

      name     = params.dig(:name)
      display_name = params.dig(:display_name)

      if( name.nil? )
        return {
          status: 404,
          message: 'missing usergroup name'
        }
      end

      payload = {
        'attrs' => {
          'display_name' => display_name
        }
      }

      Network.put(         host: name,
        url: format( '%s/objects/usergroups/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options,
        payload: payload )

    end

    # delete a usergroup
    #
    # @param [Hash] params
    # @option params [String] :name usergroup to delete
    #
    # @example
    #   @icinga.delete_usergroup(name: 'foo')
    #
    # @return [Hash] result
    #
    def delete_usergroup( params = {} )

      name = params.dig(:name)

      if( name.nil? )
        return {
          status: 404,
          message: 'missing usergroup name'
        }
      end

      Network.delete(         host: name,
        url: format( '%s/objects/usergroups/%s?cascade=1', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options )

    end

    # returns all usersgroups
    #
    # @param [Hash] params
    # @option params [String] :name ('') optional for a single usergroup
    #
    # @example to get all users
    #    @icinga.usergroups
    #
    # @example to get one user
    #    @icinga.usergroups(name: 'icingaadmins')
    #
    # @return [Hash] returns a hash with all usergroups
    #
    def usergroups( params = {} )

      name = params.dig(:name)

      Network.get(         host: name,
        url: format( '%s/objects/usergroups/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options )

    end

    # returns true if the usergroup exists
    #
    # @param [String] name the name of the usergroups
    #
    # @example
    #    @icinga.exists_usergroup?('icingaadmins')
    #
    # @return [Bool] returns true if the usergroup exists
    #
    def exists_usergroup?( name )

      result = usergroups( name: name )
      result = JSON.parse( result ) if  result.is_a?( String )
      status = result.dig(:status)

      return true if  !status.nil? && status == 200
      false
    end

  end
end
