
module Icinga2

  module Notifications


    def enableHostNotification( host )

      return hostNotification( { :name => host, :enable_notifications => true } )
    end


    def disableHostNotification( host )

      return self.hostNotification( { :name => host, :enable_notifications => false } )
    end


    def enableServiceNotification( params = {} )

      host    = params.get(:host)
      service = params.get(:service)

      if( host == nil )

        return {
          :status  => 404,
          :message => 'missing host name'
        }
      end

      return self.serviceNotification( { :name => host, :service => service, :enable_notifications => true } )
    end


    def disableServiceNotification( host )

      return self.serviceNotification( { :name => host, :enable_notifications => false } )
    end


    def enableHostgroupNotification( group )

      return self.hostgroupNotification( { :host_group => group, :enable_notifications => true } )
    end


    def disableHostgroupNotification( group )

      return self.hostgroupNotification( { :host_group => group, :enable_notifications => false } )
    end


    def listNotifications( params = {} )

      name = params.dig(:name)

      result = Network.get( {
        :host     => name,
        :url      => sprintf( '%s/v1/objects/notifications/%s', @icingaApiUrlBase, name ),
        :headers  => @headers,
        :options  => @options
      } )

      return JSON.pretty_generate( result )

    end


    # PRIVATE SECTION
    #
    def hostNotification( params = {} )

      name          = params.dig(:name)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        "attrs"     => {
          "enable_notifications" => notifications
        }
      }

      result = Network.post( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/hosts/%s', @icingaApiUrlBase, name ),
        :headers => @headers,
        :options => @options,
        :payload => payload
      } )

      logger.debug( result.class.to_s )

      return JSON.pretty_generate( result )

    end


    def hostgroupNotification( params = {} )

      group         = params.dig(:host_group)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        "filter"    => sprintf( '"%s" in host.groups', group ),
        "attrs"     => {
          "enable_notifications" => notifications
        }
      }

      result = Network.post( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/services', @icingaApiUrlBase ),
        :headers => @headers,
        :options => @options,
        :payload => payload
      } )

      logger.debug( result.class.to_s )

      return JSON.pretty_generate( result )

    end


    def serviceNotification( params = {} )

      name          = params.dig(:name)
      service       = params.dig(:service)
      notifications = params.dig(:enable_notifications) || false

      payload = {
        "filter"    => sprintf( 'host.name=="%s"', name ),
        "attrs"     => {
          "enable_notifications" => notifications
        }
      }

      logger.debug( payload )
      logger.debug( sprintf( '%s/v1/objects/services', @icingaApiUrlBase ) )

      result = Network.post( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/services', @icingaApiUrlBase ),
        :headers => @headers,
        :options => @options,
        :payload => payload
      } )

      logger.debug( result.class.to_s )

      return JSON.pretty_generate( result )

    end


  end

end
