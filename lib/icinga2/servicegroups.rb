
# frozen_string_literal: true

module Icinga2

  # namespace for servicegroup handling
  module Servicegroups

    # add a servicegroup
    #
    # @param [Hash] params
    # @option params [String] :name servicegroup to create
    # @option params [String] :display_name the displayed name
    #
    # @example
    #   @icinga.add_servicegroup(name: 'foo', display_name: 'FOO')
    #
    # @return [Hash] result
    #
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

      Network.put(         host: name,
        url: format( '%s/v1/objects/servicegroups/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options,
        payload: payload )

    end

    # delete a servicegroup
    #
    # @param [Hash] params
    # @option params [String] :name servicegroup to delete
    #
    # @example
    #   @icinga.delete_servicegroup(name: 'foo')
    #
    # @return [Hash] result
    #
    def delete_servicegroup( params = {} )

      name = params.dig(:name)

      if( name.nil? )
        return {
          status: 404,
          message: 'missing servicegroup name'
        }
      end

      Network.delete(         host: name,
        url: format( '%s/v1/objects/servicegroups/%s?cascade=1', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options )

    end

    # returns all servicegroups
    #
    # @param [Hash] params
    # @option params [String] :name ('') optional for a single servicegroup
    #
    # @example to get all users
    #    @icinga.servicegroups
    #
    # @example to get one user
    #    @icinga.servicegroups(name: 'disk')
    #
    # @return [Hash] returns a hash with all servicegroups
    #
    def servicegroups( params = {} )

      name = params.dig(:name)

      Network.get(         host: name,
        url: format( '%s/v1/objects/servicegroups/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options )

    end

    # returns true if the servicegroup exists
    #
    # @param [String] name the name of the servicegroups
    #
    # @example
    #    @icinga.exists_servicegroup?('disk')
    #
    # @return [Bool] returns true if the servicegroup exists
    #
    def exists_servicegroup?( name )
      result = servicegroups( name: name )
      result = JSON.parse( result ) if  result.is_a?( String )

      status = result.dig(:status)

      return true if  !status.nil? && status == 200
      false
    end

  end
end
