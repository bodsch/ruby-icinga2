
# frozen_string_literal: true

module Icinga2

  # namespace for downtimes handling
  #
  # Schedule a downtime for hosts and services.
  #
  module Downtimes

    # add downtime
    #
    # @param [Hash] params
    # @option params [String] host_name
    # @option params [String] host_group
    # @option params [String] type 'host' or 'service' downtime
    # @option params [Integer] start_time (Time.new.to_i) Timestamp marking the beginning of the downtime. (required)
    # @option params [Integer] end_time Timestamp marking the end of the downtime.  (required)
    # @option params [String] author Name of the author. (required)
    # @option params [String] comment Comment text. (required)
    # @option params [String] config_owner
    # @option params [Integer] duration Duration of the downtime in seconds if fixed is set to false. (Required for flexible downtimes.)
    # @option params [Integer] entry_time
    # @option params [Bool] fixed (true) Defaults to true. If true, the downtime is fixed otherwise flexible. See downtimes for more information.
    # @option params [String] scheduled_by
    # @option params [String] service_name
    # @option params [String] triggered_by Sets the trigger for a triggered downtime. See downtimes for more information on triggered downtimes.
    #
    # @example
    #    param = {
    #      name: 'test',
    #      type: 'service',
    #      host_name: 'icinga2',
    #      comment: 'test downtime',
    #      author: 'icingaadmin',
    #      start_time: Time.now.to_i,
    #      end_time: Time.now.to_i + 20
    #    }
    #    add_downtime(param)
    #
    # @return [Hash]
    #
    def add_downtime( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing \'params\'') if( params.size.zero? )

      host_name       = validate( params, required: false, var: 'host_name', type: String )
      host_group      = validate( params, required: false, var: 'host_group', type: String )
      start_time      = validate( params, required: false, var: 'start_time', type: Integer ) || Time.now.to_i
      end_time        = validate( params, required: false, var: 'end_time', type: Integer )
      author          = validate( params, required: true, var: 'author', type: String )
      comment         = validate( params, required: true, var: 'comment', type: String )
      type            = validate( params, required: false, var: 'type', type: String )
      fixed           = validate( params, required: false, var: 'fixed', type: Boolean ) || true
      duration_required = true if( fixed == false )
      duration        = validate( params, required: duration_required, var: 'duration', type: Integer )
      entry_time      = validate( params, required: false, var: 'entry_time', type: Integer )
      scheduled_by    = validate( params, required: false, var: 'scheduled_by', type: String )
      service_name    = validate( params, required: false, var: 'service_name', type: String )
      triggered_by    = validate( params, required: false, var: 'triggered_by', type: String )
      config_owner    = validate( params, required: false, var: 'config_owner', type: String )
      filter          = nil

      # sanitychecks
      #
      raise ArgumentError.new(format('wrong downtype type. only \'host\' or \'service\' allowed, given \%s\'', type)) if( %w[host service].include?(type.downcase) == false )
      raise ArgumentError.new('choose \'host_name\' or \'host_group\', not both') unless( host_group.nil? || host_name.nil? )
      raise ArgumentError.new(format('these \'author\' are not exists: \'%s\'', author)) unless( exists_user?( author ) )
      raise ArgumentError.new('Missing downtime \'end_time\'') if( end_time.nil? )
      raise ArgumentError.new('\'end_time\' are equal or smaller then \'start_time\'') if( end_time.to_i <= start_time )

      # TODO
      #  - more flexibility (e.g. support scheduled_by ...)

      unless( host_name.nil? )
        return { 'code' => 404, 'name' => host_name, 'status' => 'Object not Found' } unless( exists_host?( host_name ) )
        filter = format( 'host.name == "%s"', host_name )
      end

      unless( host_group.nil? )
        return { 'code' => 404, 'name' => host_group, 'status' => 'Object not Found' } unless( exists_hostgroup?( host_group ) )
        filter = format( '"%s" in host.groups', host_group )
      end

      payload = {
        type: type.capitalize, # we need the first char as Uppercase
        filter: filter,
        fixed: fixed,
        start_time: start_time,
        end_time: end_time,
        author: author,
        comment: comment,
        duration: duration,
        entry_time: entry_time,
        scheduled_by: scheduled_by,
        host_name: host_name,
        host_group: host_group,
        service_name: service_name,
        triggered_by: triggered_by,
        config_owner: config_owner
      }

      # remove all empty attrs
      payload.reject!{ |_k, v| v.nil? }

      post(
        url: format( '%s/actions/schedule-downtime', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # return downtimes
    #
    # @example
    #    downtimes
    #
    # @return [Array]
    #
    def downtimes

      api_data(
        url: format( '%s/objects/downtimes'   , @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )
    end

  end
end
