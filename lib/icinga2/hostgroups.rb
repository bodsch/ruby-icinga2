
# frozen_string_literal: false

module Icinga2

  # namespace for hostgroup handling
  module Hostgroups

    # add a hostgroup
    #
    # @param [Hash] params
    # @option params [String] host_group hostgroup to create
    # @option params [String] display_name the displayed name
    # @option params [String] notes
    # @option params [String] notes_url
    # @option params [String] action_url
    # @option params [Hash] vars ({})
    #
    # @example
    #   add_hostgroup(host_group: 'foo', display_name: 'FOO')
    #
    # @return [Hash] result
    #
    def add_hostgroup( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing \'params\'') if( params.size.zero? )

      host_group = validate( params, required: true, var: 'host_group', type: String )
      display_name = validate( params, required: false, var: 'display_name', type: String )
      notes = validate( params, required: false, var: 'notes', type: String )
      notes_url = validate( params, required: false, var: 'notes_url', type: String )
      action_url = validate( params, required: false, var: 'action_url', type: String )
      vars   = validate( params, required: false, var: 'vars', type: Hash ) || {}

      payload = {
        attrs: {
          display_name: display_name,
          notes: notes,
          notes_url: notes_url,
          action_url: action_url,
          vars: vars
        }
      }

      # remove all empty attrs
      payload.reject!{ |_k, v| v.nil? }
      payload[:attrs].reject!{ |_k, v| v.nil? }

      put(
        url: format('%s/objects/hostgroups/%s', @icinga_api_url_base, host_group),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # delete a hostgroup
    #
    # @param [Hash] params
    # @option params [String] name hostgroup to delete
    # @option params [Bool] cascade (false) delete hostgroup also when other objects depend on it
    #
    # @example
    #   delete_hostgroup(name: 'foo')
    #   delete_hostgroup(name: 'foo', cascade: true)
    #
    # @return [Hash] result
    #
    def delete_hostgroup( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing \'params\'') if( params.size.zero? )

      name = validate( params, required: true, var: 'name', type: String )
      cascade = validate( params, required: false, var: 'cascade', type: Boolean ) || false

      return { 'code' => 404, 'status' => 'Object not Found' } if( exists_hostgroup?( name ) == false )

      url = format( '%s/objects/hostgroups/%s%s', @icinga_api_url_base, name, cascade.is_a?(TrueClass) ? '?cascade=1' : nil )

      delete(
        url: url,
        headers: @headers,
        options: @options
      )
    end

    # returns all usersgroups
    #
    # @param [String] host_group (nil) optional for a single hostgroup
    #
    # @example to get all users
    #    hostgroups
    #
    # @example to get one user
    #    hostgroups(host_group: 'linux-servers')
    #
    # @return [Hash] returns a hash with all hostgroups
    #
    def hostgroups( host_group = nil )

      raise ArgumentError.new(format('wrong type. \'host_group\' must be an String, given \'%s\'', host_group.class.to_s)) unless( host_group.nil? || host_group.is_a?(String) )

      url = format( '%s/objects/hostgroups'   , @icinga_api_url_base )
      url = format( '%s/objects/hostgroups/%s', @icinga_api_url_base, host_group ) unless( host_group.nil? )

      api_data(
        url: url,
        headers: @headers,
        options: @options
      )
    end

    # returns true if the hostgroup exists
    #
    # @param [String] host_group the name of the hostgroup
    #
    # @example
    #    exists_hostgroup?('linux-servers')
    #
    # @return [Bool] returns true if the hostgroup exists
    #
    def exists_hostgroup?( host_group )

      raise ArgumentError.new(format('wrong type. \'host_group\' must be an String, given \'%s\'', host_group.class.to_s)) unless( host_group.is_a?(String) )
      raise ArgumentError.new('Missing \'host_group\'') if( host_group.size.zero? )

      result = hostgroups(host_group)
      result = JSON.parse( result ) if( result.is_a?(String) )
      result = result.first if( result.is_a?(Array) )

      return false if( result.is_a?(Hash) && result.dig('code') == 404 )

      true
    end

  end
end
