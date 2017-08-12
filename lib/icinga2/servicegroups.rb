
# frozen_string_literal: true

module Icinga2

  # namespace for servicegroup handling
  module Servicegroups

    # add a servicegroup
    #
    # @param [Hash] params
    # @option params [String] :service_group servicegroup to create
    # @option params [String] :display_name the displayed name
    #
    # @example
    #   @icinga.add_servicegroup(service_group: 'foo', display_name: 'FOO')
    #
    # @return [Hash] result
    #
    def add_servicegroup( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      service_group = params.dig(:service_group)
      display_name = params.dig(:display_name)

      raise ArgumentError.new('Missing service_group') if( service_group.nil? )
      raise ArgumentError.new('Missing display_name') if( display_name.nil? )

      payload = { 'attrs' => { 'display_name' => display_name } }

      Network.put(
        url: format( '%s/objects/servicegroups/%s', @icinga_api_url_base, service_group ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # delete a servicegroup
    #
    # @param [Hash] params
    # @option params [String] :service_group servicegroup to delete
    #
    # @example
    #   @icinga.delete_servicegroup(service_group: 'foo')
    #
    # @return [Hash] result
    #
    def delete_servicegroup( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      service_group = params.dig(:service_group)

      raise ArgumentError.new('Missing service_group') if( service_group.nil? )

      Network.delete(
        url: format( '%s/objects/servicegroups/%s?cascade=1', @icinga_api_url_base, service_group ),
        headers: @headers,
        options: @options
      )
    end

    # returns all servicegroups
    #
    # @param [Hash] params
    # @option params [String] :service_group ('') optional for a single servicegroup
    #
    # @example to get all users
    #    @icinga.servicegroups
    #
    # @example to get one user
    #    @icinga.servicegroups(service_group: 'disk')
    #
    # @return [Hash] returns a hash with all servicegroups
    #
    def servicegroups( params = {} )

      service_group = params.dig(:service_group)

      url =
      if( service_group.nil? )
        format( '%s/objects/servicegroups'   , @icinga_api_url_base )
      else
        format( '%s/objects/servicegroups/%s', @icinga_api_url_base, service_group )
      end

      data = Network.api_data(
        url: url,
        headers: @headers,
        options: @options
      )

      return data.dig('results') if( data.dig(:status).nil? )

      nil
    end

    # checks if the servicegroup exists
    #
    # @param [String] service_group the name of the servicegroup
    #
    # @example
    #    @icinga.exists_servicegroup?('disk')
    #
    # @return [Bool] returns true if the servicegroup exists
    #
    def exists_servicegroup?( service_group )

      raise ArgumentError.new('only String are allowed') unless( service_group.is_a?(String) )
      raise ArgumentError.new('Missing service_group') if( service_group.size.zero? )


      result = servicegroups( service_group: service_group )
      result = JSON.parse( result ) if  result.is_a?( String )

      return true if  !result.nil? && result.is_a?(Array)

      false
    end

  end
end
