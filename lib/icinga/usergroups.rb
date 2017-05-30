
module Icinga

  module Usergroups

    def addUsergroup( params = {} )

      name     = params.dig(:name)
      vars     = params.dig(:vars) || {}

      if( name == nil )

        return {
          :status  => 404,
          :message => 'missing usergroup name'
        }
      end

      payload = {
        "attrs" => {
          "display_name"         => name
        }
      }

      result = Network.put( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/usergroups/%s', @icingaApiUrlBase, name ),
        :headers => @headers,
        :options => @options,
        :payload => payload
      } )

      return JSON.pretty_generate( result )

    end


    def deleteUsergroup( params = {} )

      name = params.dig(:name)

      if( name == nil )

        return {
          :status  => 404,
          :message => 'missing usergroup name'
        }
      end

      result = Network.delete( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/usergroups/%s?cascade=1', @icingaApiUrlBase, name ),
        :headers => @headers,
        :options => @options
      } )

      return JSON.pretty_generate( result )

    end


    def listUsergroups( params = {} )

      name = params.dig(:name)

      result = Network.get( {
        :host     => name,
        :url      => sprintf( '%s/v1/objects/usergroups/%s', @icingaApiUrlBase, name ),
        :headers  => @headers,
        :options  => @options
      } )

      return JSON.pretty_generate( result )

    end


    def existsUsergroup?( name )

      result = self.listUsergroups( { :name => name } )

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


