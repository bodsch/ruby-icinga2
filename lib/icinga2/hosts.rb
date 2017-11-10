
# frozen_string_literal: true
module Icinga2

  # namespace for host handling
  module Hosts

    # add host
    #
    # @param [Hash] params
    # @option params [String] :name
    # @option params [String] :fqdn
    # @option params [String] :display_name
    # @option params [Bool] :enable_notifications (false)
    # @option params [Integer] :max_check_attempts (3)
    # @option params [Integer] :check_interval (60)
    # @option params [Integer] :retry_interval (45)
    # @option params [String] :notes
    # @option params [String] :notes_url
    # @option params [String] :action_url
    # @option params [Hash] :vars ({})
    #
    # @example
    #    param = {
    #      name: 'foo',
    #      address: 'foo.bar.com',
    #      display_name: 'test node',
    #      max_check_attempts: 5,
    #      notes: 'test node'
    #    }
    #    @icinga.add_host(param)
    #
    # @return [Hash]
    #
    def add_host( params )

      raise ArgumentError.new('only Hash is allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      action_url = params.dig(:action_url)
      address = params.dig(:address)
      address6 = params.dig(:address6)
      check_command = params.dig(:check_command)
      check_interval = params.dig(:check_interval)
      check_period = params.dig(:check_period)
      check_timeout = params.dig(:check_timeout)
      command_endpoint = params.dig(:command_endpoint)
      display_name = params.dig(:display_name)
      enable_active_checks = params.dig(:enable_active_checks)
      enable_event_handler = params.dig(:enable_event_handler)
      enable_flapping = params.dig(:enable_flapping) || false
      enable_notifications = params.dig(:enable_notifications)
      enable_passive_checks = params.dig(:enable_passive_checks)
      enable_perfdata = params.dig(:enable_perfdata)
      event_command = params.dig(:event_command)
      flapping_threshold = params.dig(:flapping_threshold)
      groups = params.dig(:groups)
      icon_image = params.dig(:icon_image)
      icon_image_alt = params.dig(:icon_image_alt)
      max_check_attempts = params.dig(:max_check_attempts)
      name = params.dig(:name)
      notes = params.dig(:notes)
      notes_url = params.dig(:notes_url)
      retry_interval = params.dig(:retry_interval)
      templates = params.dig(:templates)
      vars = params.dig(:vars) || {}
      volatile = params.dig(:volatile)

      raise ArgumentError.new('missing name') if( name.nil? )

      %w[action_url
         address
         address6
         check_command
         check_period
         command_endpoint
         display_name
         event_command
         icon_image
         icon_image_alt
         name
         notes
         notes_url].each do |attr|
        raise ArgumentError.new("only String for #{attr} is allowed") unless( eval(attr).is_a?(String) || eval(attr).nil? )
      end

      %w[check_interval
         flapping_threshold
         max_check_attempts
         retry_interval].each do |attr|
        raise ArgumentError.new("only Integer for #{attr} is allowed") unless( eval(attr).is_a?(Integer) || eval(attr).nil? )
      end

      %w[enable_active_checks
         enable_event_handler
         enable_flapping
         enable_notifications
         enable_passive_checks
         enable_perfdata
         volatile].each do |attr|
        raise ArgumentError.new("only Integer for #{attr} is allowed") unless( eval(attr).is_a?(TrueClass) || eval(attr).is_a?(FalseClass) || eval(attr).nil? )
      end

      %w[groups templates].each do |attr|
        raise ArgumentError.new("only Array for #{attr} is allowed") unless( eval(attr).is_a?(Array) || eval(attr).nil? )
      end

      raise ArgumentError.new('only Hash for vars are allowed') unless( vars.is_a?(Hash) )

      if( address.nil? )
        # build FQDN
        address = Socket.gethostbyname( name ).first
      end

      payload = {
        'templates' => templates,
        'attrs'     => {
          'action_url' => action_url,
          'address' => address,
          'address6' => address6,
          'check_period' => check_period,
          'check_command' => check_command,
          'check_interval' => check_interval,
          'check_timeout' => check_timeout,
          'command_endpoint' => command_endpoint,
          'display_name' => display_name,
          'enable_active_checks' => enable_active_checks,
          'enable_event_handler' => enable_event_handler,
          'enable_flapping' => enable_flapping,
          'enable_notifications' => enable_notifications,
          'enable_passive_checks' => enable_passive_checks,
          'enable_perfdata' => enable_perfdata,
          'event_command' => event_command,
          'flapping_threshold' => flapping_threshold,
          'groups' => groups,
          'icon_image' => icon_image,
          'icon_image_alt' => icon_image_alt,
          'max_check_attempts' => max_check_attempts,
          'notes' => notes,
          'notes_url' => notes_url,
          'retry_interval' => retry_interval,
          'volatile' => volatile
        }
      }

      payload['attrs']['vars'] = vars unless vars.empty?

      if( @icinga_cluster == true && !@icinga_satellite.nil? )
        payload['attrs']['zone'] = @icinga_satellite
      end

      # logger.debug( JSON.pretty_generate( payload ) )
       payload.reject!{ |_k, v| v.nil? }
       payload['attrs'].reject!{ |_k, v| v.nil? }

      Network.put(
        url: format( '%s/objects/hosts/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # delete a host
    #
    # @param [Hash] params
    # @option params [String] :host host to delete
    #
    # @example
    #   @icinga.delete_host(host: 'foo')
    #
    # @return [Hash] result
    #
    def delete_host( params )

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      host = params.dig(:host)

      raise ArgumentError.new('Missing host') if( host.nil? )

      Network.delete(
        url: format( '%s/objects/hosts/%s?cascade=1', @icinga_api_url_base, host ),
        headers: @headers,
        options: @options
      )
    end

    # return hosts
    #
    # @param [Hash] params
    # @option params [String] :host
    # @option params [String] :attrs
    # @option params [String] :filter
    # @option params [String] :joins
    #
    # @example to get all hosts
    #    @icinga.hosts
    #
    # @example to get one host
    #    @icinga.hosts(host: 'icinga2')
    #
    # @return [Array]
    #
    def hosts( params = {} )

      host   = params.dig(:host)
      attrs  = params.dig(:attrs)
      filter = params.dig(:filter)
      joins  = params.dig(:joins)

      payload['attrs']  = attrs  unless attrs.nil?
      payload['filter'] = filter unless filter.nil?
      payload['joins']  = joins  unless joins.nil?

      data = Network.api_data(
        url: format( '%s/objects/hosts/%s', @icinga_api_url_base, host ),
        headers: @headers,
        options: @options
      )

      return data.dig('results') if( data.dig(:status).nil? )

      nil
    end

    # returns true if the host exists
    #
    # @param [String] host_name
    #
    # @example
    #    @icinga.exists_host?('icinga2')
    #
    # @return [Bool]
    #
    def exists_host?( host_name )

      raise ArgumentError.new('only String are allowed') unless( host_name.is_a?(String) )
      raise ArgumentError.new('Missing host_name') if( host_name.size.zero? )

      result = hosts( host: host_name )
      result = JSON.parse( result ) if  result.is_a?( String )

      return true if  !result.nil? && result.is_a?(Array)

      false
    end

    # returns host objects
    #
    # @param [Hash] params
    # @option params [Array] :attrs (['name', 'state', 'acknowledgement', 'downtime_depth', 'last_check'])
    # @option params [Array] :filter ([])
    # @option params [Array] :joins ([])
    #
    # @example with default attrs and joins
    #    @icinga.host_objects
    #
    # @example
    #    @icinga.host_objects(attrs: ['name', 'state'])
    #
    # @return [Hash]
    #
    def host_objects( params = {} )

      attrs   = params.dig(:attrs)
      filter  = params.dig(:filter)
      joins   = params.dig(:joins)

#       raise ArgumentError.new('only Array for attrs are allowed') unless( attrs.is_a?(Hash) )
#       raise ArgumentError.new('only Array for filter are allowed') unless( filter.is_a?(Hash) )
#       raise ArgumentError.new('only Array for joins are allowed') unless( joins.is_a?(Hash) )

      payload = {}
      results = nil

      if( attrs.nil? )
        attrs = %w[name state acknowledgement downtime_depth last_check]
      end

      payload['attrs']  = attrs  unless attrs.nil?
      payload['filter'] = filter unless filter.nil?
      payload['joins']  = joins  unless joins.nil?

      data = Network.api_data(
        url: format( '%s/objects/hosts', @icinga_api_url_base ),
        headers: @headers,
        options: @options,
        payload: payload
      )

      status  = data.dig(:status)

      if( status.nil? )

        results = data.dig('results')

        unless( results.nil? )

          all_hosts = results.clone

          unless( all_hosts.nil? )

            # global var for count of all hosts
            @hosts_all           = all_hosts.size
            # global var for count of all host with a problem
            @hosts_problems      = count_problems(results)
            # global var for count of all gost with state HOSTS_DOWN
            @hosts_problems_down     = count_problems(results, Icinga2::HOSTS_DOWN)
            @hosts_problems_critical = count_problems(results, Icinga2::HOSTS_CRITICAL)
            @hosts_problems_unknown  = count_problems(results, Icinga2::HOSTS_UNKNOWN)

          end
        end
      end

      results
    end

    # returns adjusted hosts state
    #
    # @example
    #    @icinga.cib_data
    #    @icinga.host_objects
    #    handled, down = @icinga.hosts_adjusted.values
    #
    #    h = @icinga.hosts_adjusted
    #    down = h.dig(:down_adjusted)
    #
    # @return [Hash]
    #    * handled_problems
    #    * down_adjusted
    #
    def hosts_adjusted

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
    #    @icinga.count_hosts_with_problems
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
    #    @icinga.list_hosts_with_problems
    #
    # @return [Hash]
    #
    def list_hosts_with_problems( max_items = 5 )

      raise ArgumentError.new('only Integer for max_items are allowed') unless( max_items.is_a?(Integer) )

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
      if( host_problems.count != 0 )
        host_problems.keys[1..max_items].each { |k,_v| host_problems_severity[k] = host_problems[k] }
      end

      host_problems_severity
    end

    # returns a counter of all hosts
    #
    # @example
    #    @icinga.host_objects
    #    @icinga.hosts_all
    #
    # @return [Integer]
    #
    def hosts_all
      @hosts_all
    end

    # returns data with host problems
    #
    # @example
    #    @icinga.host_objects
    #    all, down, critical, unknown = @icinga.host_problems.values
    #
    #    p = @icinga.host_problems
    #    down = h.dig(:down)
    #
    # @return [Hash]
    #    * all
    #    * down
    #    * critical
    #    * unknown
    #
    def host_problems

      problems_all      = @hosts_problems.nil?           ? 0 : @hosts_problems
      problems_down     = @hosts_problems_down.nil?      ? 0 : @hosts_problems_down
      problems_critical = @hosts_problems_critical.nil?  ? 0 : @hosts_problems_critical
      problems_unknown  = @hosts_problems_unknown.nil?   ? 0 : @hosts_problems_unknown

      {
        all: problems_all.to_i,
        down: problems_down.to_i,
        critical: problems_critical.to_i,
        unknown: problems_unknown.to_i
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

      raise ArgumentError.new('only Hash are allowed') unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      state           = params.dig('attrs','state')
      acknowledgement = params.dig('attrs','acknowledgement') || 0
      downtime_depth  = params.dig('attrs','downtime_depth')  || 0

      raise ArgumentError.new('only Float for state are allowed') unless( state.is_a?(Float) )
      raise ArgumentError.new('only Float for acknowledgement are allowed') unless( acknowledgement.is_a?(Float) )
      raise ArgumentError.new('only Float for downtime_depth are allowed') unless( downtime_depth.is_a?(Float) )

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
