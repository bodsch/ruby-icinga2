
# frozen_string_literal: true

module Icinga2

  #
  #
  #
  module Notifications

    #
    #
    #
    def enable_host_notification( host )

      host_notification( name: host, enable_notifications: true )
    end

    #
    #
    #
    def disable_host_notification( host )

      host_notification( name: host, enable_notifications: false )
    end

    #
    #
    #
    def enable_service_notification( params = {} )

      host    = params.get(:host)
      service = params.get(:service)

      if( host.nil? )

        return {
          status: 404,
          message: 'missing host name'
        }
      end

      service_notification( name: host, service: service, enable_notifications: true )
    end

    #
    #
    #
    def disable_service_notification( host )

      service_notification( name: host, enable_notifications: false )
    end

    #
    #
    #
    def enable_hostgroup_notification( group )

      hostgroup_notification( host_group: group, enable_notifications: true )
    end

    #
    #
    #
    def disable_hostgroup_notification( group )

      hostgroup_notification( host_group: group, enable_notifications: false )
    end

    #
    #
    #
    def notifications( params = {} )

      name = params.dig(:name)

      result = Network.get(         host: name,
        url: format( '%s/v1/objects/notifications/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )

    end


    # PRIVATE SECTION
    #
    def host_notification( params = {} )

      name          = params.dig(:name)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        'attrs'     => {
          'enable_notifications' => notifications
        }
      }

      result = Network.post(         host: name,
        url: format( '%s/v1/objects/hosts/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options,
        payload: payload )

      JSON.pretty_generate( result )

    end

    #
    #
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

      result = Network.post(         host: name,
        url: format( '%s/v1/objects/services', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload )

      JSON.pretty_generate( result )

    end

    #
    #
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

      result = Network.post(         host: name,
        url: format( '%s/v1/objects/services', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload )

      JSON.pretty_generate( result )

    end

  end
end
