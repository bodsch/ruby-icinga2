
# frozen_string_literal: true
module Icinga2

  module Downtimes


    def addDowntime( params = {} )

      name            = params.dig(:name)
      hostName        = params.dig(:host)
#      serviceName     = params.dig(:service)
      hostGroup       = params.dig(:host_group)
      startTime       = params.dig(:start_time) || Time.now.to_i
      endTime         = params.dig(:end_time)
      author          = params.dig(:author)
      comment         = params.dig(:comment)
      type            = params.dig(:type)
      filter          = nil

      # sanitychecks
      #
      if( name.nil? )

        return {
          status: 404,
          message: 'missing downtime name'
        }
      end

      if( %w[host service].include?(type.downcase) == false )

        return {
          status: 404,
          message: "wrong downtype type. only 'host' or' service' allowed ('#{type}' giving"
        }
      else
        # we need the first char as Uppercase
        type.capitalize!
      end

      if( !hostGroup.nil? && !hostName.nil? )

        return {
          status: 404,
          message: 'choose host or host_group, not both'
        }

      end

      if( !hostName.nil? )

        filter = format( 'host.name=="%s"', hostName )
      elsif( !hostGroup.nil? )

        # check if hostgroup available ?
        #
        filter = format( '"%s" in host.groups', hostGroup )
      else

        return {
          status: 404,
          message: 'missing host or host_group for downtime'
        }
      end

      if( comment.nil? )

        return {
          status: 404,
          message: 'missing downtime comment'
        }
      end

      if( author.nil? )

        return {
          status: 404,
          message: 'missing downtime author'
        }
      else

        if( existsUser?( author ) == false )

          return {
            status: 404,
            message: "these author ar not exists: #{author}"
          }
        end
      end


      if( endTime.nil? )

        return {
          status: 404,
          message: 'missing end_time'
        }
      else

        if( endTime.to_i <= startTime )

          return {
            status: 404,
            message: 'end_time are equal or smaller then start_time'
          }
        end
      end

#       logger.debug( Time.at( startTime ).strftime( '%Y-%m-%d %H:%M:%S' ) )
#       logger.debug( Time.at( endTime ).strftime( '%Y-%m-%d %H:%M:%S' ) )

      payload = {
        'type'        => type,
        'start_time'  => startTime,
        'end_time'    => endTime,
        'author'      => author,
        'comment'     => comment,
        'fixed'       => true,
        'duration'    => 30,
        'filter'      => filter
      }

#       logger.debug( JSON.pretty_generate( payload ) )

      result = Network.post(         host: name,
        url: format( '%s/v1/actions/schedule-downtime', @icingaApiUrlBase ),
        headers: @headers,
        options: @options,
        payload: payload )

      logger.debug( result.class.to_s )

      JSON.pretty_generate( result )


      # schedule downtime for a host
      #  --data '{ "type": "Host", "filter": "host.name==\"api_dummy_host_1\"", ... }'

      # schedule downtime for all services of a host
      #  --data '{ "type": "Service", "filter": "host.name==\"api_dummy_host_1\"", ... }'

      # schedule downtime for all hosts and services in a hostgroup
      #  --data '{ "type": "Host", "filter": "\"api_dummy_hostgroup\" in host.groups", ... }'

      #  --data '{ "type": "Service", "filter": "\"api_dummy_hostgroup\" in host.groups)", ... }'



    end


    def listDowntimes( params = {} )

      name = params.dig(:name)

      result = Network.get(         host: name,
        url: format( '%s/v1/objects/downtimes/%s', @icingaApiUrlBase, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )


    end


  end

end
