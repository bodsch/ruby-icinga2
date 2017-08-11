
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

      if( state.is_a?(Fixnum) )
        compare_states.push(state)
      end

      objects = JSON.parse(objects) if objects.is_a?(String)

#       puts "state: #{state}"
#       puts "compare_states: #{compare_states}"

      f = objects.select {
        |t|
          t.dig('attrs','state') == state &&
          t.dig('attrs','downtime_depth').zero? &&
          t.dig('attrs','acknowledgement').zero?
      }

      f.size

#       unless( objects.nil? )
#
#         objects.each do |n|
#
#           attrs = n.dig('attrs')
#           next if(attrs.nil?)
#
#           state = attrs.dig('state')           || 0
#           next if( state.zero? )
#
#           downtime_depth  = attrs.dig('downtime_depth')  || 0
#           acknowledgement = attrs.dig('acknowledgement') || 0
#
#           if( compare_states.include?( state ) && downtime_depth.zero? && acknowledgement.zero? )
#             problems += 1
#           end
#
#         end
#       end
#       problems
    end

  end
end
