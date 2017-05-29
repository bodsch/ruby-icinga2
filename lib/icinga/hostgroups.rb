
module Icinga

  module Hostgroups

    def addHostgroup( params = {} )

      code        = nil
      result      = {}

      name        = params.dig(:name)
      displayName = params.dig(:display_name)

      if( name == nil )

        return {
          :status  => 404,
          :message => 'no name for the hostgroup'
        }
      end

      payload = {
        "attrs" => {
          "display_name"         => displayName
        }
      }

      result = Network.put( {
        :url     => sprintf( '%s/v1/objects/hostgroups/%s', @icingaApiUrlBase, name ),
        :headers => @headers,
        :options => @options,
        :payload => payload
      } )

      return JSON.pretty_generate( result )

    end


    def deleteHostgroup( params = {} )

      name = params.dig(:name)

      if( name == nil )

        return {
          :status  => 404,
          :message => 'no name for the hostgroup'
        }
      end

      result = Network.delete( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/hostgroups/%s?cascade=1', @icingaApiUrlBase, name ),
        :headers => @headers,
        :options => @options
      } )

      return JSON.pretty_generate( result )

    end


    def listHostgroups( params = {} )

      host = params.dig(:host)

      result = Network.get( {
        :host => host,
        :url  => sprintf( '%s/v1/objects/hostgroups/%s', @icingaApiUrlBase, host ),
        :headers  => @headers,
        :options  => @options
      } )

      return JSON.pretty_generate( result )

    end


    def existsHostgroup?( host )

      result = Network.get( {
        :host => host,
        :url  => sprintf( '%s/v1/objects/hostgroups/%s', @icingaApiUrlBase, host ),
        :headers  => @headers,
        :options  => @options
      } )

      status = result.dig(:status)

      if( status != nil && status == 200 )
        return true
      end

      return false

    end


  end

end
