
module Icinga

  module Users

    def addUser( params = {} )

      name     = params.dig(:name)
      email    = params.dig(:email)
      pager    = params.dig(:pager)
      groups   = params.dig(:groups) || []

      if( name == nil )

        return {
          :status  => 404,
          :message => 'no name for the user'
        }
      end

      if( !groups.is_a?( Array ) )

        return {
          :status  => 404,
          :message => 'groups must be an array'
        }
      end

      payload = {
        "attrs" => {
          "display_name"         => name,
          "email"                => email,
          "pager"                => pager,
          "enable_notifications" => false
        }
      }

      if( ! groups.empty? )
        payload['attrs']['groups'] = vars
      end

      logger.debug( payload )


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

