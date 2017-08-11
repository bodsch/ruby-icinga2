
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

      if( host.nil? )

        return {
          status: 404,
          message: 'missing host name'
        }
      end

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

      if( host.nil? )
        return {
          status: 404,
          message: 'missing host name'
        }
      end

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
    def enable_hostgroup_notification( params = {} )

      host = params.dig(:host)
      host_group = params.dig(:host_group)

      if( host.nil? )
        return {
          status: 404,
          message: 'missing host name'
        }
      end

      if( host_group.nil? )
        return {
          status: 404,
          message: 'missing host_group name'
        }
      end

      hostgroup_notification( host: host, host_group: host_group, enable_notifications: true )
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
    def disable_hostgroup_notification( params = {} )

      host = params.dig(:host)
      host_group = params.dig(:host_group)

      if( host.nil? )
        return {
          status: 404,
          message: 'missing host name'
        }
      end

      if( host_group.nil? )
        return {
          status: 404,
          message: 'missing host_group name'
        }
      end

      hostgroup_notification( host: host, host_group: host_group, enable_notifications: false )
    end

    # return all notifications
    #
    # @param [Hash] params
    # @option params [String] name
    #
    # @return [Hash]
    #
    def notifications( params = {} )

      name = params.dig(:name)

      Network.get(         host: name,
        url: format( '%s/objects/notifications/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options )

    end


    # function for host notifications
    # @private
    #
    # @param [Hash] params
    # @option params [String] name
    # @option params [Bool] enable_notifications (false)
    #
    # @return [Hash]
    #
    private
    def host_notification( params = {} )

      name          = params.dig(:name)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        'attrs'     => {
          'enable_notifications' => notifications
        }
      }

      Network.post(         host: name,
        url: format( '%s/objects/hosts/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options,
        payload: payload )

    end

    # function for hostgroup notifications
    # @private
    #
    # @param [Hash] params
    # @option params [String] host_group
    # @option params [Bool] enable_notifications (false)
    #
    # @return [Hash]
    #
    private
    def hostgroup_notification( params = {} )

      host          = params.dig(:host)
      group         = params.dig(:host_group)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        'filter'    => format( '"%s" in host.groups', group ),
        'attrs'     => {
          'enable_notifications' => notifications
        }
      }

      Network.post(         host: host,
        url: format( '%s/objects/services', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload )

    end

    # function for service notifications
    # @private
    #
    # @param [Hash] params
    # @option params [String] name
    # @option params [Bool] enable_notifications (false)
    #
    # @return [Hash]
    #
    private
    def service_notification( params = {} )

      name          = params.dig(:name)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        'filter'    => format( 'host.name=="%s"', name ),
        'attrs'     => {
          'enable_notifications' => notifications
        }
      }

      Network.post(         host: name,
        url: format( '%s/objects/services', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload )

    end

  end
end
