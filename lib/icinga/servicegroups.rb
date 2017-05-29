
module Icinga

  module Servicegroups


    def addServicegroup( params = {} )

      code        = nil
      result      = {}

      name        = params.dig(:name)
      displayName = params.dig(:display_name)

      if( name == nil )

        return {
          :status  => 404,
          :message => 'no name for the servicegroup'
        }
      end

      payload = {
        "attrs" => {
          "display_name"         => displayName
        }
      }

      result = Network.put( {
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
          :message => 'no name for the servicegroup'
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

      host = params.dig(:host)

      result = Network.get( {
        :host => host,
        :url  => sprintf( '%s/v1/objects/servicegroups/%s', @icingaApiUrlBase, host ),
        :headers  => @headers,
        :options  => @options
      } )

      return JSON.pretty_generate( result )

    end


    def existsServicegroup?( host )

      result = Network.get( {
        :host => host,
        :url  => sprintf( '%s/v1/objects/servicegroups/%s', @icingaApiUrlBase, host ),
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


#curl -k -s -u icingaadmin:icinga 'https://localhost:5665/v1/objects/servicegroups/testgrp' \
#    -X PUT -d '{ "attrs": { "name" : "testgrp" ,"display_name" : "testgrp" , "state_loaded" :true }}'
