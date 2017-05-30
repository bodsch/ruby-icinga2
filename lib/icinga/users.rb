
module Icinga

  module Users

    def addUser( params = {} )

      name     = params.dig(:name) || nil
      vars     = params.dig(:vars) || {}

      if( name == nil )

        return {
          :status  => 404,
          :message => 'no name for the user'
        }
      end

      payload = {
        "attrs" => {
          "display_name"         => name,
          "enable_notifications" => false
        }
      }

      result = Network.delete( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/users/%s', @icingaApiUrlBase, name ),
        :headers => @headers,
        :options => @options
      } )

      return JSON.pretty_generate( result )

    end


    def deleteUser( params = {} )

      name = params.dig(:name) || nil

      if( name == nil )

        return {
          :status  => 500,
          :message => 'internal Server Error'
        }
      end

      result = Network.delete( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/users/%s?cascade=1', @icingaApiUrlBase, name ),
        :headers => @headers,
        :options => @options
      } )

      return JSON.pretty_generate( result )

    end


    def listUsers( params = {} )

      name = params.dig(:name)

      result = Network.get( {
        :host     => name,
        :url      => sprintf( '%s/v1/objects/users/%s', @icingaApiUrlBase, name ),
        :headers  => @headers,
        :options  => @options
      } )

      return JSON.pretty_generate( result )

    end


    def existsUser?( user )

      result = self.listUsers( { :name => user } )

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

