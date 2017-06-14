
# frozen_string_literal: true
module Icinga2

  module Downtimes


    def add_downtime( params = {} )

      name            = params.dig(:name)
      host_name       = params.dig(:host)
      host_group      = params.dig(:host_group)
      start_time      = params.dig(:start_time) || Time.now.to_i
      end_time        = params.dig(:end_time)
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
        type = type.capitalize
      end

      if( !host_group.nil? && !host_name.nil? )
        return {
          status: 404,
          message: 'choose host or host_group, not both'
        }
      end

      if( !host_name.nil? )

        filter = format( 'host.name=="%s"', host_name )
      elsif( !host_group.nil? )

        # check if hostgroup available ?
        #
        filter = format( '"%s" in host.groups', host_group )
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
      elsif( exists_user?( author ) == false )
        return {
          status: 404,
          message: "these author ar not exists: #{author}"
        }
      end


      if( end_time.nil? )
        return {
          status: 404,
          message: 'missing end_time'
        }
      elsif( end_time.to_i <= start_time )
        return {
          status: 404,
          message: 'end_time are equal or smaller then start_time'
        }
      end

#       logger.debug( Time.at( start_time ).strftime( '%Y-%m-%d %H:%M:%S' ) )
#       logger.debug( Time.at( end_time ).strftime( '%Y-%m-%d %H:%M:%S' ) )

      payload = {
        'type'        => type,
        'start_time'  => start_time,
        'end_time'    => end_time,
        'author'      => author,
        'comment'     => comment,
        'fixed'       => true,
        'duration'    => 30,
        'filter'      => filter
      }

#       logger.debug( JSON.pretty_generate( payload ) )

      result = Network.post(         host: name,
        url: format( '%s/v1/actions/schedule-downtime', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload )


      # schedule downtime for a host
      #  --data '{ "type": "Host", "filter": "host.name==\"api_dummy_host_1\"", ... }'

      # schedule downtime for all services of a host
      #  --data '{ "type": "Service", "filter": "host.name==\"api_dummy_host_1\"", ... }'

      # schedule downtime for all hosts and services in a hostgroup
      #  --data '{ "type": "Host", "filter": "\"api_dummy_hostgroup\" in host.groups", ... }'

      #  --data '{ "type": "Service", "filter": "\"api_dummy_hostgroup\" in host.groups)", ... }'

      JSON.pretty_generate( result )

    end


    def downtimes( params = {} )

      name = params.dig(:name)

      result = Network.get(         host: name,
        url: format( '%s/v1/objects/downtimes/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options )

      JSON.pretty_generate( result )


    end


  end

end
