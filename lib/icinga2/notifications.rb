
# frozen_string_literal: true

module Icinga2

  # namespace for servicegroup handling
  module Notifications

    # enable host notifications
    #
    # @param [String] host
    #
    # @example
    #    @icinga.enable_host_notification('icinga')
    #
    # @return [Hash]
    #
    def enable_host_notification( host )

      raise ArgumentError.new(format('wrong type. \'host\' must be an String, given \'%s\'', host.class.to_s)) unless( host.is_a?(String) )
      raise ArgumentError.new('missing \'host\'') if( host.size.zero? )

      return { 'code' => 404, 'status' => 'Object not Found' } if( exists_host?( host ) == false )

      host_notification( name: host, enable_notifications: true )
    end

    # disable host notifications
    #
    # @param [String] host
    #
    # @example
    #    @icinga.disable_host_notification('icinga')
    #
    # @return [Hash]
    #
    def disable_host_notification( host )

      raise ArgumentError.new(format('wrong type. \'host\' must be an String, given \'%s\'', host.class.to_s)) unless( host.is_a?(String) )
      raise ArgumentError.new('missing \'host\'') if( host.size.zero? )

      return { 'code' => 404, 'status' => 'Object not Found' } if( exists_host?( host ) == false )

      host_notification( name: host, enable_notifications: false )
    end

    # enable service notifications
    #
    # @param [String] host
    #
    # @example
    #    @icinga.enable_service_notification('icinga')
    #
    # @return [Hash]
    #
    def enable_service_notification( host )

      raise ArgumentError.new(format('wrong type. \'host\' must be an String, given \'%s\'', host.class.to_s)) unless( host.is_a?(String) )
      raise ArgumentError.new('missing \'host\'') if( host.size.zero? )

      return { 'code' => 404, 'status' => 'Object not Found' } if( exists_host?( host ) == false )

      service_notification( name: host, enable_notifications: true )
    end

    # disable service notifications
    #
    # @param [String] host
    #
    # @example
    #    @icinga.disable_service_notification('icinga')
    #
    # @return [Hash]
    #
    def disable_service_notification( host )

      raise ArgumentError.new(format('wrong type. \'host\' must be an String, given \'%s\'', host.class.to_s)) unless( host.is_a?(String) )
      raise ArgumentError.new('missing \'host\'') if( host.size.zero? )

      return { 'code' => 404, 'status' => 'Object not Found' } if( exists_host?( host ) == false )

      service_notification( name: host, enable_notifications: false )
    end

    # enable hostgroup notifications
    #
    # @param [Hash] params
    # @option params [String] host
    # @option params [String] host_group
    #
    # @example
    #    @icinga.enable_hostgroup_notification(host: 'icinga2', host_group: 'linux-servers')
    #
    # @return [Hash]
    #
    def enable_hostgroup_notification( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing \'params\'') if( params.size.zero? )

      host_group = params.dig(:host_group)
      raise ArgumentError.new('Missing host_group') if( host_group.nil? )

      return { 'code' => 404, 'status' => 'Object not Found' } if( exists_hostgroup?( host_group ) == false )

      hostgroup_notification( host_group: host_group, enable_notifications: true )
    end

    # disable hostgroup notifications
    #
    # @param [Hash] params
    # @option params [String] host
    # @option params [String] host_group
    #
    # @example
    #    @icinga.disable_hostgroup_notification(host: 'icinga2', host_group: 'linux-servers')
    #
    # @return [Hash]
    #
    def disable_hostgroup_notification( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing \'params\'') if( params.size.zero? )

      host_group = params.dig(:host_group)
      raise ArgumentError.new('Missing host_group') if( host_group.nil? )

      return { 'code' => 404, 'status' => 'Object not Found' } if( exists_hostgroup?( host_group ) == false )

      hostgroup_notification( host_group: host_group, enable_notifications: true )
    end

    # return all notifications
    #
    #
    # @return [Array]
    #
    def notifications

      api_data(
        url: format( '%s/objects/notifications', @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )
    end

    protected
    # function for host notifications
    # @api protected
    #
    # @param [Hash] params
    # @option params [String] name
    # @option params [Bool] enable_notifications (false)
    #
    # @return [Hash]
    #
    def host_notification( params = {} )

      name          = params.dig(:name)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        'attrs'     => {
          'enable_notifications' => notifications
        }
      }

      post(
        url: format( '%s/objects/hosts/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # function for hostgroup notifications
    # @api protected
    #
    # @param [Hash] params
    # @option params [String] host_group
    # @option params [Bool] enable_notifications (false)
    #
    # @return [Hash]
    #
    def hostgroup_notification( params = {} )

      group         = params.dig(:host_group)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        'filter'    => format( '"%s" in host.groups', group ),
        'attrs'     => {
          'enable_notifications' => notifications
        }
      }

      post(
        url: format( '%s/objects/services', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # function for service notifications
    # @api protected
    #
    # @param [Hash] params
    # @option params [String] name
    # @option params [Bool] enable_notifications (false)
    #
    # @return [Hash]
    #
    def service_notification( params = {} )

      name          = params.dig(:name)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        'filter'    => format( 'host.name=="%s"', name ),
        'attrs'     => {
          'enable_notifications' => notifications
        }
      }

      post(
        url: format( '%s/objects/services', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

  end
end
