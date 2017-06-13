
# frozen_string_literal: true
module Icinga2

  module Notifications


    def enableHostNotification( host )

      hostNotification( name: host, enable_notifications: true )
    end


    def disableHostNotification( host )

      hostNotification( name: host, enable_notifications: false )
    end


    def enableServiceNotification( params = {} )

      host    = params.get(:host)
      service = params.get(:service)

      if( host.nil? )

        return {
          status: 404,
          message: 'missing host name'
        }
      end

      serviceNotification( name: host, service: service, enable_notifications: true )
    end


    def disableServiceNotification( host )

      serviceNotification( name: host, enable_notifications: false )
    end


    def enableHostgroupNotification( group )

      hostgroupNotification( host_group: group, enable_notifications: true )
    end


    def disableHostgroupNotification( group )

      hostgroupNotification( host_group: group, enable_notifications: false )
    end


    def listNotifications( params = {} )

      name = params.dig(:name)

      result = Network.get(         host: name,
        url: format( '%s/v1/objects/notifications/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )

    end


    # PRIVATE SECTION
    #
    def hostNotification( params = {} )

      name          = params.dig(:name)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        'attrs'     => {
          'enable_notifications' => notifications
        }
      }

      result = Network.post(         host: name,
        url: format( '%s/v1/objects/hosts/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options,
        payload: payload )

      logger.debug( result.class.to_s )

      JSON.pretty_generate( result )

    end


    def hostgroupNotification( params = {} )

      group         = params.dig(:host_group)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        'filter'    => format( '"%s" in host.groups', group ),
        'attrs'     => {
          'enable_notifications' => notifications
        }
      }

      result = Network.post(         host: name,
        url: format( '%s/v1/objects/services', @icingaApiUrlBase ),
        headers: @headers,
        options: @options,
        payload: payload )

      logger.debug( result.class.to_s )

      JSON.pretty_generate( result )

    end


    def serviceNotification( params = {} )

      name          = params.dig(:name)
      service       = params.dig(:service)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        'filter'    => format( 'host.name=="%s"', name ),
        'attrs'     => {
          'enable_notifications' => notifications
        }
      }

      logger.debug( payload )
      logger.debug( format( '%s/v1/objects/services', @icingaApiUrlBase ) )

      result = Network.post(         host: name,
        url: format( '%s/v1/objects/services', @icingaApiUrlBase ),
        headers: @headers,
        options: @options,
        payload: payload )

      logger.debug( result.class.to_s )

      JSON.pretty_generate( result )

    end


  end

end
