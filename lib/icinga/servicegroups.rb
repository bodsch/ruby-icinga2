
module Icinga

  module Servicegroups


    def addServicegroup( params = {} )

      name        = params.dig(:name)
      displayName = params.dig(:display_name)

      if( name == nil )

        return {
          :status  => 404,
          :message => 'missing servicegroup name'
        }
      end

      payload = {
        "attrs" => {
          "display_name"         => displayName
        }
      }

      result = Network.put( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/servicegroups/%s', @icingaApiUrlBase, name ),
        :headers => @headers,
        :options => @options,
        :payload => payload
      } )

      return JSON.pretty_generate( result )

    end


    def deleteServicegroup( params = {} )

      name = params.dig(:name)

      if( name == nil )

        return {
          :status  => 404,
          :message => 'missing servicegroup name'
        }
      end

      result = Network.delete( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/servicegroups/%s?cascade=1', @icingaApiUrlBase, name ),
        :headers => @headers,
        :options => @options
      } )

      return JSON.pretty_generate( result )

    end


    def listServicegroups( params = {} )

      name = params.dig(:name)

      result = Network.get( {
        :host     => name,
        :url      => sprintf( '%s/v1/objects/servicegroups/%s', @icingaApiUrlBase, name ),
        :headers  => @headers,
        :options  => @options
      } )

      return JSON.pretty_generate( result )

    end


    def existsServicegroup?( name )


      result = self.listServicegroups( { :name => name } )

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
