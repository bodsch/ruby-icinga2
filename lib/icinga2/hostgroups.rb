
# frozen_string_literal: false

module Icinga2

  # namespace for hostgroup handling
  module Hostgroups

    # add a hostgroup
    #
    # @param [Hash] params
    # @option params [String] :host_group hostgroup to create
    # @option params [String] :display_name the displayed name
    #
    # @example
    #   @icinga.add_hostgroup(host_group: 'foo', display_name: 'FOO')
    #
    # @return [Hash] result
    #
    def add_hostgroup(params = {})

      host_group   = params.dig(:host_group)
      display_name = params.dig(:display_name)

      if( host_group.nil? )
        {
          status: 404,
          message: 'no name for the hostgroup'
        }
      end

      if( display_name.nil? )
        {
          status: 404,
          message: 'no display name for the hostgroup'
        }
      end

      Network.put(
        url: format('%s/objects/hostgroups/%s', @icinga_api_url_base, host_group),
        headers: @headers,
        options: @options,
        payload: { 'attrs' => { 'display_name' => display_name } }
      )
    end

    # delete a hostgroup
    #
    # @param [Hash] params
    # @option params [String] :name hostgroup to delete
    #
    # @example
    #   @icinga.delete_hostgroup(host_group: 'foo')
    #
    # @return [Hash] result
    #
    def delete_hostgroup(params = {})

      host_group = params.dig(:host_group)

      if host_group.nil?
        {
          status: 404,
          message: 'no name for the hostgroup'
        }
      end

      Network.delete(
        url: format('%s/objects/hostgroups/%s?cascade=1', @icinga_api_url_base, host_group),
        headers: @headers,
        options: @options
      )
    end

    # returns all usersgroups
    #
    # @param [Hash] params
    # @option params [String] :host_group ('') optional for a single hostgroup
    #
    # @example to get all users
    #    @icinga.hostgroups
    #
    # @example to get one user
    #    @icinga.hostgroups(host_group: 'linux-servers')
    #
    # @return [Hash] returns a hash with all hostgroups
    #
    def hostgroups(params = {})

      host_group = params.dig(:host_group)

      url =
      if( host_group.nil? )
        format( '%s/objects/hostgroups'   , @icinga_api_url_base )
      else
        format( '%s/objects/hostgroups/%s', @icinga_api_url_base, host_group )
      end

      data = Network.api_data(
        url: url,
        headers: @headers,
        options: @options
      )

      return data.dig('results') if( data.dig(:status).nil? )

      nil
    end

    # returns true if the hostgroup exists
    #
    # @param [String] name the name of the hostgroup
    #
    # @example
    #    @icinga.exists_hostgroup?('linux-servers')
    #
    # @return [Bool] returns true if the hostgroup exists
    #
    def exists_hostgroup?(name)
      result = hostgroups(host_group: name)
      result = JSON.parse( result ) if  result.is_a?( String )

      return true if  !result.nil? && result.is_a?(Array)

      false
    end

  end
end
