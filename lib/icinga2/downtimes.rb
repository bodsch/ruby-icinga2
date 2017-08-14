
# frozen_string_literal: true

module Icinga2

  # namespace for downtimes handling
  module Downtimes

    # add downtime
    #
    # @param [Hash] params
    # @option params [String] :name
    # @option params [String] :host
    # @option params [String] :host_group
    # @option params [Integer] :start_time (Time.new.to_i)
    # @option params [Integer] :end_time
    # @option params [String] :author
    # @option params [String] :comment
    # @option params [String] :type 'host' or 'service' downtime
    #
    # @example
    #    param = {
    #      name: 'test',
    #      type: 'service',
    #      host: 'icinga2',
    #      comment: 'test downtime',
    #      author: 'icingaadmin',
    #      start_time: Time.now.to_i,
    #      end_time: Time.now.to_i + 20
    #    }
    #    @icinga.add_downtime(param)
    #
    # @return [Hash]
    #
    def add_downtime( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

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
      raise ArgumentError.new('Missing name') if( name.nil? )
      raise ArgumentError.new("wrong downtype type. only 'host' or' service' allowed ('#{type}' giving)") if( %w[host service].include?(type.downcase) == false )
      raise ArgumentError.new('choose host or host_group, not both') if( !host_group.nil? && !host_name.nil? )
      raise ArgumentError.new('Missing downtime author') if( author.nil? )
      raise ArgumentError.new("these author ar not exists: #{author}") unless( exists_user?( author ) )
      raise ArgumentError.new('Missing downtime comment') if( comment.nil? )
      raise ArgumentError.new('Missing downtime end_time') if( end_time.nil? )
      raise ArgumentError.new('end_time are equal or smaller then start_time') if( end_time.to_i <= start_time )

      if( !host_name.nil? )

        filter = format( 'host.name=="%s"', host_name )
      elsif( !host_group.nil? )

        # check if hostgroup available ?
        #
        filter = format( '"%s" in host.groups', host_group )
      end

      payload = {
        'type'        => type.capitalize, # we need the first char as Uppercase
        'start_time'  => start_time,
        'end_time'    => end_time,
        'author'      => author,
        'comment'     => comment,
        'fixed'       => true,
        'duration'    => 30,
        'filter'      => filter
      }

      Network.post(
        url: format( '%s/actions/schedule-downtime', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # return downtimes
    #
    # @example
    #    @icinga.downtimes
    #
    # @return [Array]
    #
    def downtimes

      data = Network.api_data(
        url: format( '%s/objects/downtimes'   , @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )

      return data.dig('results') if( data.dig(:status).nil? )

      nil
    end

  end
end
