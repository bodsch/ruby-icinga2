
# frozen_string_literal: true

module Icinga2

  # namespace for servicegroup handling
  module Servicegroups

    # add a servicegroup
    #
    # @param [Hash] params
    # @option params [String] service_group servicegroup to create
    # @option params [String] display_name the displayed name
    # @option params [String] notes
    # @option params [String] notes_url
    # @option params [String] action_url
    #
    # @example
    #   add_servicegroup(service_group: 'foo', display_name: 'FOO')
    #
    # @return [Hash] result
    #
    def add_servicegroup( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing \'params\'') if( params.size.zero? )

      service_group = validate( params, required: true, var: 'service_group', type: String )
      display_name = validate( params, required: true, var: 'display_name', type: String )
      notes = validate( params, required: false, var: 'notes', type: String )
      notes_url = validate( params, required: false, var: 'notes_url', type: String )
      action_url = validate( params, required: false, var: 'action_url', type: String )

      payload = {
        attrs: {
          display_name: display_name,
          notes: notes,
          notes_url: notes_url,
          action_url: action_url
        }
      }

      # remove all empty attrs
      payload.reject!{ |_k, v| v.nil? }
      payload[:attrs].reject!{ |_k, v| v.nil? }

      put(
        url: format( '%s/objects/servicegroups/%s', @icinga_api_url_base, service_group ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # delete a servicegroup
    #
    # @param [Hash] params
    # @option params [String] name servicegroup to delete
    # @option params [Bool] cascade (false) delete servicegroup also when other objects depend on it
    #
    # @example
    #   delete_servicegroup('foo')
    #
    # @return [Array] result
    #
    def delete_servicegroup( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing \'params\'') if( params.size.zero? )

      name = validate( params, required: true, var: 'name', type: String )
      cascade = validate( params, required: false, var: 'cascade', type: Boolean ) || false

      return { 'code' => 404, 'status' => 'Object not Found' } if( exists_servicegroup?( name ) == false )

      url = format( '%s/objects/servicegroups/%s%s', @icinga_api_url_base, name, cascade.is_a?(TrueClass) ? '?cascade=1' : nil )

      delete(
        url: url,
        headers: @headers,
        options: @options
      )
    end

    # returns all servicegroups
    #
    # @param [String] service_group (nil) optional for a single servicegroup
    #
    # @example to get all users
    #    servicegroups
    #
    # @example to get one user
    #    servicegroups(service_group: 'disk')
    #
    # @return [Array] returns a hash with all servicegroups
    #
    def servicegroups( service_group = nil )

      raise ArgumentError.new(format('wrong type. \'service_group\' must be an String, given \'%s\'', service_group.class.to_s)) unless( service_group.nil? || service_group.is_a?(String) )

      url = format( '%s/objects/servicegroups'   , @icinga_api_url_base )
      url = format( '%s/objects/servicegroups/%s', @icinga_api_url_base, service_group ) unless( service_group.nil? )

      api_data(
        url: url,
        headers: @headers,
        options: @options
      )
    end

    # checks if the servicegroup exists
    #
    # @param [String] service_group the name of the servicegroup
    #
    # @example
    #    exists_servicegroup?('disk')
    #
    # @return [Bool] returns true if the servicegroup exists
    #
    def exists_servicegroup?( service_group )

      raise ArgumentError.new(format('wrong type. \'service_group\' must be an String, given \'%s\'', service_group.class.to_s)) unless( service_group.is_a?(String) )
      raise ArgumentError.new('Missing \'service_group\'') if( service_group.size.zero? )

      result = servicegroups(service_group)
      result = JSON.parse( result ) if  result.is_a?( String )
      result = result.first if( result.is_a?(Array) )

      return false if( result.is_a?(Hash) && result.dig('code') == 404 )

      true
    end

  end
end
