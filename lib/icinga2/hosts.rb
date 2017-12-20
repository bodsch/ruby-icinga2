
# frozen_string_literal: true
module Icinga2

  # namespace for host handling
  module Hosts

    # add host
    #
    # @param [Hash] params
    # @option params [String] name
    # @option params [String] address
    # @option params [String] address6
    # @option params [String] display_name
    # @option params [Bool] enable_notifications (false)
    # @option params [Integer] max_check_attempts (3)
    # @option params [Integer] check_interval (60)
    # @option params [Integer] retry_interval (45)
    # @option params [String] notes
    # @option params [String] notes_url
    # @option params [String] action_url
    # @option params [String] check_command
    # @option params [Integer] check_interval
    # @option params [String] check_period
    # @option params [Integer] check_timeout
    # @option params [String] command_endpoint
    # @option params [Bool] enable_active_checks
    # @option params [Bool] enable_event_handler
    # @option params [Bool] enable_flapping
    # @option params [Bool] enable_passive_checks
    # @option params [Bool] enable_perfdata
    # @option params [String] event_command
    # @option params [Integer] flapping_threshold
    # @option params [Integer] flapping_threshold_high
    # @option params [Integer] flapping_threshold_low
    # @option params [String] icon_image
    # @option params [String] icon_image_alt
    # @option params [Integer] retry_interval
    # @option params [Bool] volatile
    # @option params [Hash] vars ({})
    #
    # @example
    #    param = {
    #      name: 'foo',
    #      address: 'foo.bar.com',
    #      display_name: 'test node',
    #      max_check_attempts: 5,
    #      notes: 'test node',
    #      vars: {
    #        description: 'host foo',
    #        os: 'Linux',
    #        partitions: {
    #          '/' => {
    #            crit: '95%',
    #            warn: '90%'
    #          }
    #        }
    #      }
    #    }
    #    add_host(param)
    #
    # @return [Hash]
    #
    def add_host( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      name    = validate( params, required: true, var: 'name', type: String )
      action_url = validate( params, required: false, var: 'action_url', type: String )
      address    = validate( params, required: false, var: 'address', type: String )
      address6   = validate( params, required: false, var: 'address6', type: String )
      check_command = validate( params, required: false, var: 'check_command', type: String )
      check_interval = validate( params, required: false, var: 'check_interval', type: Integer ) || 60
      check_period   = validate( params, required: false, var: 'check_period', type: Integer )
      check_timeout = validate( params, required: false, var: 'check_timeout', type: Integer )
      command_endpoint = validate( params, required: false, var: 'command_endpoint', type: String )
      display_name   = validate( params, required: false, var: 'display_name', type: String )
      enable_active_checks = validate( params, required: false, var: 'enable_active_checks', type: Boolean )
      enable_event_handler = validate( params, required: false, var: 'enable_event_handler', type: Boolean )
      enable_flapping   = validate( params, required: false, var: 'enable_flapping', type: Boolean )
      enable_notifications = validate( params, required: false, var: 'enable_notifications', type: Boolean ) || false
      enable_passive_checks = validate( params, required: false, var: 'enable_passive_checks', type: Boolean )
      volatile = validate( params, required: false, var: 'volatile', type: Boolean )
      enable_perfdata   = validate( params, required: false, var: 'enable_perfdata', type: Boolean )
      event_command = validate( params, required: false, var: 'event_command', type: String )
      flapping_threshold = validate( params, required: false, var: 'flapping_threshold', type: Integer )
      groups   = validate( params, required: false, var: 'groups', type: Array )
      icon_image    = validate( params, required: false, var: 'icon_image', type: String )
      icon_image_alt   = validate( params, required: false, var: 'icon_image_alt', type: String )
      notes    = validate( params, required: false, var: 'notes', type: String )
      notes_url   = validate( params, required: false, var: 'notes_url', type: String )
      max_check_attempts = validate( params, required: false, var: 'max_check_attempts', type: Integer ) || 3
      retry_interval   = validate( params, required: false, var: 'retry_interval', type: Integer ) || 45
      templates   = validate( params, required: false, var: 'templates', type: Array ) || [ 'generic-host' ]
      vars   = validate( params, required: false, var: 'vars', type: Hash ) || {}
      zone   = validate( params, required: false, var: 'zone', type: String )

      address = Socket.gethostbyname( name ).first if( address.nil? )

      payload = {
        templates: templates,
        attrs: {
          action_url: action_url,
          address: address,
          address6: address6,
          check_period: check_period,
          check_command: check_command,
          check_interval: check_interval,
          check_timeout: check_timeout,
          command_endpoint: command_endpoint,
          display_name: display_name,
          enable_active_checks: enable_active_checks,
          enable_event_handler: enable_event_handler,
          enable_flapping: enable_flapping,
          enable_notifications: enable_notifications,
          enable_passive_checks: enable_passive_checks,
          enable_perfdata: enable_perfdata,
          event_command: event_command,
          flapping_threshold: flapping_threshold,
          groups: groups,
          icon_image: icon_image,
          icon_image_alt: icon_image_alt,
          max_check_attempts: max_check_attempts,
          notes: notes,
          notes_url: notes_url,
          retry_interval: retry_interval,
          volatile: volatile,
          zone: zone,
          vars: vars
        }
      }

      # remove all empty attrs
      payload.reject!{ |_k, v| v.nil? }
      payload[:attrs].reject!{ |_k, v| v.nil? }

#       puts JSON.pretty_generate  payload

      put(
        url: format( '%s/objects/hosts/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # delete a host
    #
    # @param [Hash] params
    # @option params [String] name host to delete
    # @option params [Bool] cascade (false) delete host also when other objects depend on it
    #
    # @example
    #   delete_host(name: 'foo')
    #   delete_host(name: 'foo', cascade: true)
    #
    #
    # @return [Hash] result
    #
    def delete_host( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      name    = validate( params, required: true, var: 'name', type: String )
      cascade = validate( params, required: false, var: 'cascade', type: Boolean ) || false

      url = format( '%s/objects/hosts/%s%s', @icinga_api_url_base, name, cascade.is_a?(TrueClass) ? '?cascade=1' : nil )

      delete(
        url: url,
        headers: @headers,
        options: @options
      )
    end

    # modify a host
    #
    # @param [Hash] params
    # @option params [String] name
    # @option params [String] name
    # @option params [String] address
    # @option params [String] address6
    # @option params [String] display_name
    # @option params [Bool] enable_notifications
    # @option params [Integer] max_check_attempts
    # @option params [Integer] check_interval
    # @option params [Integer] retry_interval
    # @option params [String] notes
    # @option params [String] notes_url
    # @option params [String] action_url
    # @option params [String] check_command
    # @option params [Integer] check_interval
    # @option params [String] check_period
    # @option params [Integer] check_timeout
    # @option params [String] command_endpoint
    # @option params [Bool] enable_active_checks
    # @option params [Bool] enable_event_handler
    # @option params [Bool] enable_flapping
    # @option params [Bool] enable_passive_checks
    # @option params [Bool] enable_perfdata
    # @option params [String] event_command
    # @option params [Integer] flapping_threshold
    # @option params [Integer] flapping_threshold_high
    # @option params [Integer] flapping_threshold_low
    # @option params [String] icon_image
    # @option params [String] icon_image_alt
    # @option params [Integer] retry_interval
    # @option params [Bool] volatile
    # @option params [Hash] vars ({})
    # @option params [Bool] merge_vars (false)
    #
    # @example
    #    param = {
    #      name: 'foo',
    #      address: 'foo.bar.com',
    #      display_name: 'Host for an example Problem',
    #      max_check_attempts: 10,
    #    }
    #
    #    param = {
    #      name: 'foo',
    #      address: 'foo.bar.com',
    #      notes: 'an demonstration object',
    #      vars: {
    #        description: 'schould be delete ASAP',
    #        os: 'Linux',
    #        partitions: {
    #          '/' => {
    #            crit: '98%',
    #            warn: '95%'
    #          }
    #        }
    #      },
    #      merge_vars: true
    #    }
    #
    #    param = {
    #      name: 'foo',
    #      address: 'foo.bar.com',
    #      vars: {
    #        description: 'removed all other custom vars',
    #      }
    #    }
    #
    #    add_host(param)
    #
    # @return [Hash]
    #
    def modify_host( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      name    = validate( params, required: true, var: 'name', type: String )
      action_url = validate( params, required: false, var: 'action_url', type: String )
      address    = validate( params, required: false, var: 'address', type: String )
      address6   = validate( params, required: false, var: 'address6', type: String )
      check_command = validate( params, required: false, var: 'check_command', type: String )
      check_interval = validate( params, required: false, var: 'check_interval', type: Integer )
      check_period   = validate( params, required: false, var: 'check_period', type: Integer )
      check_timeout = validate( params, required: false, var: 'check_timeout', type: Integer )
      command_endpoint = validate( params, required: false, var: 'command_endpoint', type: String )
      display_name   = validate( params, required: false, var: 'display_name', type: String )
      enable_active_checks = validate( params, required: false, var: 'enable_active_checks', type: Boolean )
      enable_event_handler = validate( params, required: false, var: 'enable_event_handler', type: Boolean )
      enable_flapping   = validate( params, required: false, var: 'enable_flapping', type: Boolean )
      enable_notifications = validate( params, required: false, var: 'enable_notifications', type: Boolean )
      enable_passive_checks = validate( params, required: false, var: 'enable_passive_checks', type: Boolean )
      volatile = validate( params, required: false, var: 'volatile', type: Boolean )
      enable_perfdata   = validate( params, required: false, var: 'enable_perfdata', type: Boolean )
      event_command = validate( params, required: false, var: 'event_command', type: String )
      flapping_threshold = validate( params, required: false, var: 'flapping_threshold', type: Integer )
      groups   = validate( params, required: false, var: 'groups', type: Array )
      icon_image    = validate( params, required: false, var: 'icon_image', type: String )
      icon_image_alt   = validate( params, required: false, var: 'icon_image_alt', type: String )
      notes    = validate( params, required: false, var: 'notes', type: String )
      notes_url   = validate( params, required: false, var: 'notes_url', type: String )
      max_check_attempts = validate( params, required: false, var: 'max_check_attempts', type: Integer )
      retry_interval   = validate( params, required: false, var: 'retry_interval', type: Integer )
      templates   = validate( params, required: false, var: 'templates', type: Array ) || [ 'generic-host' ]
      vars   = validate( params, required: false, var: 'vars', type: Hash ) || {}
      zone   = validate( params, required: false, var: 'zone', type: String )
      merge_vars = validate( params, required: false, var: 'merge_vars', type: Boolean ) || false

      # check if host exists
      return { 'code' => 404, 'name' => name, 'status' => 'Object not Found' } unless( exists_host?( name ) )

      # merge the new with the old vars
      if( merge_vars == true )
        current_host = hosts( name: name )
        current_host_vars = current_host.first
        current_host_vars = current_host_vars.dig('attrs','vars')
        current_host_vars = current_host_vars.deep_string_keys
        vars = vars.deep_string_keys unless( vars.empty? )
        vars = current_host_vars.merge( vars )
      end

      payload = {
        templates: templates,
        attrs: {
          action_url: action_url,
          address: address,
          address6: address6,
          check_period: check_period,
          check_command: check_command,
          check_interval: check_interval,
          check_timeout: check_timeout,
          command_endpoint: command_endpoint,
          display_name: display_name,
          enable_active_checks: enable_active_checks,
          enable_event_handler: enable_event_handler,
          enable_flapping: enable_flapping,
          enable_notifications: enable_notifications,
          enable_passive_checks: enable_passive_checks,
          enable_perfdata: enable_perfdata,
          event_command: event_command,
          flapping_threshold: flapping_threshold,
          groups: groups,
          icon_image: icon_image,
          icon_image_alt: icon_image_alt,
          max_check_attempts: max_check_attempts,
          notes: notes,
          notes_url: notes_url,
          retry_interval: retry_interval,
          volatile: volatile,
          zone: zone,
          vars: vars
        }
      }

      # remove all empty attrs
      payload.reject!{ |_k, v| v.nil? }
      payload[:attrs].reject!{ |_k, v| v.nil? }

      post(
        url: format( '%s/objects/hosts/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end


    # return hosts
    #
    # @param [Hash] params
    # @option params [String] name
    # @option params [Array] attrs
    # @option params [String] filter
    # @option params [Array] joins
    #
    # @example to get all hosts
    #    hosts
    #
    # @example to get one host
    #    hosts( name: 'icinga2')
    #
    # @return [Array]
    #
    def hosts( params = {} )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )

      name    = validate( params, required: false, var: 'name', type: String )
      attrs   = validate( params, required: false, var: 'attrs', type: Array )
      filter  = validate( params, required: false, var: 'filter', type: String )
      joins   = validate( params, required: false, var: 'joins', type: Array )

      payload = {
        attrs: attrs,
        filter: filter,
        joins: joins
      }
      payload.reject!{ |_k, v| v.nil? }

      api_data(
        url: format( '%s/objects/hosts/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # returns true if the host exists
    #
    # @param [String] host_name
    #
    # @example
    #    exists_host?('icinga2')
    #
    # @return [Bool]
    #
    def exists_host?( host_name )

      raise ArgumentError.new(format('wrong type. \'host_name\' must be an String, given \'%s\'',host_name.class.to_s)) unless( host_name.is_a?(String) )
      raise ArgumentError.new('Missing host_name') if( host_name.size.zero? )

      result = hosts( name: host_name )
      result = JSON.parse( result ) if( result.is_a?(String) )
      result = result.first if( result.is_a?(Array) )

      return false if( result.is_a?(Hash) && result.dig('code') == 404 )

      true
    end

    # returns host objects
    #
    # @param [Hash] params
    # @option params [Array] attrs (['name', 'state', 'acknowledgement', 'downtime_depth', 'last_check'])
    # @option params [String] filter ([])
    # @option params [Array] joins ([])
    #
    # @example with default attrs and joins
    #    host_objects
    #
    # @example
    #    host_objects(attrs: ['name', 'state'])
    #
    # @return [Hash]
    #
    def host_objects( params = {} )

      attrs   = validate( params, required: false, var: 'attrs', type: Array ) || %w[name state acknowledgement downtime_depth last_check]
      filter  = validate( params, required: false, var: 'filter', type: String )
      joins   = validate( params, required: false, var: 'joins', type: Array )

      payload = {
        attrs: attrs,
        filter: filter,
        joins: joins
      }
      payload.reject!{ |_k, v| v.nil? }

      data = api_data(
        url: format( '%s/objects/hosts', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload
      )

      @last_host_objects_called = Time.now.to_i

      if( !data.nil? && data.is_a?(Array) )
        all_hosts = data.clone
        unless( all_hosts.nil? )
          # global var for count of all hosts
          @hosts_all           = all_hosts.size
          # global var for count of all host with a problem
          @hosts_problems      = count_problems(all_hosts)
          # global var for count of all gost with state HOSTS_DOWN
          @hosts_problems_down     = count_problems(all_hosts, Icinga2::HOSTS_DOWN)
          @hosts_problems_critical = count_problems(all_hosts, Icinga2::HOSTS_CRITICAL)
          @hosts_problems_unknown  = count_problems(all_hosts, Icinga2::HOSTS_UNKNOWN)
        end
      end

      data
    end

    # returns adjusted hosts state
    # OBSOLETE
    #
    # @example
    #    handled, down = hosts_adjusted.values
    #
    #    h = hosts_adjusted
    #    down = h.dig(:down_adjusted)
    #
    # @return [Hash]
    #    * handled_problems
    #    * down_adjusted
    #
    def hosts_adjusted

      puts 'function hosts_adjusted() is obsolete'
      puts 'Please use host_problems()'

      cib_data if((Time.now.to_i - @last_cib_data_called).to_i > @last_call_timeout)
      host_objects if((Time.now.to_i - @last_host_objects_called).to_i > @last_call_timeout)

      raise ArgumentError.new('Integer for @hosts_problems_down needed') unless( @hosts_problems_down.is_a?(Integer) )
      raise ArgumentError.new('Integer for @hosts_problems_critical needed') unless( @hosts_problems_critical.is_a?(Integer) )
      raise ArgumentError.new('Integer for @hosts_problems_unknown needed') unless( @hosts_problems_unknown.is_a?(Integer) )
      raise ArgumentError.new('Integer for @hosts_down needed') unless( @hosts_down.is_a?(Integer) )

      # calculate host problems adjusted by handled problems
      # count togther handled host problems
      handled_problems = @hosts_problems_down + @hosts_problems_critical + @hosts_problems_unknown
      down_adjusted    = @hosts_down - handled_problems

      {
        handled_problems: handled_problems.to_i,
        down_adjusted: down_adjusted.to_i
      }
    end

    # return count of hosts with problems
    #
    # @example
    #    count_hosts_with_problems
    #
    # @return [Integer]
    #
    def count_hosts_with_problems

      host_data = host_objects
      host_data = JSON.parse(host_data) if  host_data.is_a?(String)

      f = host_data.select { |t| t.dig('attrs','state') != 0 && t.dig('attrs','downtime_depth').zero? && t.dig('attrs','acknowledgement').zero? }

      f.size
    end

    # return a list of hosts with problems
    #
    # @param [Integer] max_items numbers of list entries
    #
    # @example
    #    list_hosts_with_problems
    #
    # @return [Hash]
    #
    def list_hosts_with_problems( max_items = 5 )

      raise ArgumentError.new(format('wrong type. \'max_items\' must be an Integer, given \'%s\'', max_items.class.to_s)) unless( max_items.is_a?(Integer) )

      host_problems = {}
      host_problems_severity = {}

      host_data = host_objects
      host_data = JSON.parse( host_data ) if host_data.is_a?(String)

      unless( host_data.nil? )
        host_data.each do |h,_v|
          name  = h.dig('name')
          state = h.dig('attrs','state')

          next if state.to_i.zero?

          host_problems[name] = host_severity(h)
        end
      end

      # get the count of problems
      #
      host_problems.keys[1..max_items].each { |k| host_problems_severity[k] = host_problems[k] } if( host_problems.count != 0 )

      host_problems_severity
    end

    # returns a counter of all hosts
    #
    # @example
    #    hosts_all
    #
    # @return [Integer]
    #
    def hosts_all
      host_objects if( @hosts_all.nil? || @hosts_all.zero? )
      @hosts_all
    end

    # returns data with host problems
    #
    # @example
    #    host_objects
    #    all, down, critical, unknown, handled, adjusted = host_problems.values
    #
    #    p = host_problems
    #    down = h.dig(:down)
    #
    # @return [Hash]
    #    * all
    #    * down
    #    * critical
    #    * unknown
    #
    def host_problems

      cib_data if((Time.now.to_i - @last_cib_data_called).to_i > @last_call_timeout)
      host_objects if((Time.now.to_i - @last_host_objects_called).to_i > @last_call_timeout)

      raise ArgumentError.new(format('wrong type. \'@hosts_problems_down\' must be an Integer, given \'%s\'', @hosts_problems_down.class.to_s)) unless( @hosts_problems_down.is_a?(Integer) )
      raise ArgumentError.new(format('wrong type. \'@hosts_problems_critical\' must be an Integer, given \'%s\'', @hosts_problems_critical.class.to_s)) unless( @hosts_problems_critical.is_a?(Integer) )
      raise ArgumentError.new(format('wrong type. \'@hosts_problems_critical\' must be an Integer, given \'%s\'', @hosts_problems_critical.class.to_s)) unless( @hosts_problems_critical.is_a?(Integer) )
      raise ArgumentError.new(format('wrong type. \'@hosts_down\' must be an Integer, given \'%s\'', @hosts_down.class.to_s)) unless( @hosts_down.is_a?(Integer) )

      problems_all      = @hosts_problems.nil?           ? 0 : @hosts_problems
      problems_down     = @hosts_problems_down.nil?      ? 0 : @hosts_problems_down
      problems_critical = @hosts_problems_critical.nil?  ? 0 : @hosts_problems_critical
      problems_unknown  = @hosts_problems_unknown.nil?   ? 0 : @hosts_problems_unknown

      # calculate host problems adjusted by handled problems
      # count togther handled host problems
      problems_handled  = @hosts_problems_down + @hosts_problems_critical + @hosts_problems_unknown
      problems_adjusted = @hosts_down - problems_handled

      {
        all: problems_all.to_i,
        down: problems_down.to_i,
        critical: problems_critical.to_i,
        unknown: problems_unknown.to_i,
        handled: problems_handled.to_i,
        adjusted: problems_adjusted.to_i
      }
    end

    protected
    # calculate a host severity
    #
    # stolen from Icinga Web 2
    # ./modules/monitoring/library/Monitoring/Backend/Ido/Query/ServicestatusQuery.php
    #
    # @param [Hash] params
    # @option params [hash] attrs ()
    #   * state [Float]
    #   * acknowledgement [Float] (default: 0)
    #   * downtime_depth [Float] (default: 0)
    #
    # @api protected
    #
    # @example
    #   host_severity( {'attrs' => { 'state' => 0.0, 'acknowledgement' => 0.0, 'downtime_depth' => 0.0 } } )
    #
    # @return [Integer]
    #
    def host_severity( params )

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      attrs = params.dig('attrs')

      state = validate( attrs, required: true, var: 'state', type: Float )
      acknowledgement = validate( attrs, required: false, var: 'acknowledgement', type: Float ) || 0
      downtime_depth = validate( attrs, required: false, var: 'downtime_depth', type: Float ) || 0

      severity = 0

      severity +=
        if acknowledgement != 0
          2
        elsif downtime_depth > 0
          1
        else
          4
        end

      severity += 16 if object_has_been_checked?(params)

      unless state.zero?
        severity +=
          if state == 1
            32
          elsif state == 2
            64
          else
            256
          end
      end

      severity
    end

  end
end
