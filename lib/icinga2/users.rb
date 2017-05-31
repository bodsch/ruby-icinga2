
module Icinga2

  module Users

    def addUser( params = {} )

      name          = params.dig(:name)
      displayName   = params.dig(:display_name)
      email         = params.dig(:email)
      pager         = params.dig(:pager)
      notifications = params.dig(:enable_notifications) || false
      groups        = params.dig(:groups) || []

      if( name == nil )

        return {
          :status  => 404,
          :message => 'missing user name'
        }
      end

      if( !groups.is_a?( Array ) )

        return {
          :status  => 404,
          :message => 'groups must be an array',
          :data    => params
        }
      end

      payload = {
        "attrs" => {
          "display_name"         => displayName,
          "email"                => email,
          "pager"                => pager,
          "enable_notifications" => notifications
        }
      }

      if( ! groups.empty? )
        payload['attrs']['groups'] = groups
      end

      groupValidate = Array.new()

      groups.each do |g|

        if( self.existsUsergroup?( g ) == false )
          groupValidate << g
        end

      end

      if( groupValidate.count != 0 )

        groups = groupValidate.join(', ')

        return {

          :status  => 404,
          :message => "these groups are not exists: #{groups}",
          :data    => params
        }

      end

      result = Network.put( {
        :host    => name,
        :url     => sprintf( '%s/v1/objects/users/%s', @icingaApiUrlBase, name ),
        :headers => @headers,
        :options => @options,
        :payload => payload
      } )

      return JSON.pretty_generate( result )

    end


    def deleteUser( params = {} )

      name = params.dig(:name)

      if( name == nil )

        return {
          :status  => 404,
          :message => 'missing user name'
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


    def existsUser?( name )

      result = self.listUsers( { :name => name } )

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

