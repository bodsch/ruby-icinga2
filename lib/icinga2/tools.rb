
# frozen_string_literal: false

module Icinga2

  # namespache for tools
  module Tools

    # returns true for the last check
    # @private
    #
    # @param [Hash] object
    #
    # @return [Bool]
    #
    def object_has_been_checked?(object)
      object.dig('attrs', 'last_check').positive?
    end

    # parse version string and extract version and revision
    #
    # @param [String] version
    #
    # @return [String, String]
    #
    def parse_version(version)

      # version = "v2.4.10-504-gab4ba18"
      # version = "v2.4.10"
      version_map = version.split('-', 2)
      version_str = version_map.first
      # strip v2.4.10 (default) and r2.4.10 (Debian)
      version_str = version_str.scan(/^[vr]+(.*)/).last.first

      revision =
      if version_map.size > 1
        version_map.last
      else
        'release'
      end

      [version_str, revision]
    end


    # return count of handled problems
    #
    # @param [Hash] objects
    # @param [Integer] state
    #
    # @example for host objects
    #    h_objects = @icinga.host_objects
    #    warning = @icinga.count_problems(h_objects, Icinga2::HOSTS_DOWN)
    #
    # @example for service objects
    #    s_objects = @icinga.service_objects
    #    warning = @icinga.count_problems(s_objects, Icinga2::SERVICE_STATE_WARNING)
    #    critical = @icinga.count_problems(s_objects, Icinga2::SERVICE_STATE_CRITICAL)
    #    unknown = @icinga.count_problems(s_objects, Icinga2::SERVICE_STATE_UNKNOWN)
    #
    # @return [Integer]
    #
    def count_problems(objects, state = nil )

#       problems = 0

      compare_states = []

      unless( state.nil? )

        # 0 = "Up"   or "OK"
        # 1 = "Down" or "Warning"
        # 2 = "Critical"
        # 3 = "Unknown"
        compare_states = [1, 2, 3]
      end

      compare_states.push(state) if( state.is_a?(Integer) )

      objects = JSON.parse(objects) if objects.is_a?(String)

      f = objects.select { |t| t.dig('attrs','state') == state && t.dig('attrs','downtime_depth').zero? && t.dig('attrs','acknowledgement').zero? }

      f.size
    end

  end
end
