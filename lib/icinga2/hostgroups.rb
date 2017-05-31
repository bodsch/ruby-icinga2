
module Icinga2

  module Hostgroups

    def addHostgroup( params = {} )

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

      name = params.dig(:name)

      result = Network.get( {
        :host     => name,
        :url      => sprintf( '%s/v1/objects/hostgroups/%s', @icingaApiUrlBase, name ),
        :headers  => @headers,
        :options  => @options
      } )

      return JSON.pretty_generate( result )

    end


    def existsHostgroup?( name )

      result = self.listHostgroups( { :name => name } )

      if( result.is_a?( String ) )
        result = JSON.parse( result )
      end

      status = result.dig('status')

      if( status != nil && status == 200 )
        return true
      end

      return false

    end


  end

end
