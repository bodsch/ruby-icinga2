
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
    # @param [Integer] status
    #
    # @example for host objects
    #    h_objects = @icinga.host_objects
    #    all_hosts = h_objects.dig(:nodes)
    #    warning = @icinga.handled_problems(all_hosts, Icinga2::HANDLED_WARNING)
    #    critical = @icinga.handled_problems(all_hosts, Icinga2::HANDLED_CRITICAL)
    #    unknown = @icinga.handled_problems(all_hosts, Icinga2::HANDLED_UNKNOWN)
    #
    # @example for service objects
    #    s_objects = @icinga.service_objects
    #    all_services = s_objects.dig(:nodes)
    #    warning = @icinga.handled_problems(all_services, Icinga2::HANDLED_WARNING)
    #    critical = @icinga.handled_problems(all_services, Icinga2::HANDLED_CRITICAL)
    #    unknown = @icinga.handled_problems(all_services, Icinga2::HANDLED_UNKNOWN)
    #
    # @return [Integer]
    #
    def handled_problems(objects, status)

      problems = 0

      objects = JSON.parse(objects) if  objects.is_a?(String)
      nodes = objects.dig(:nodes)

      unless !nodes

        nodes.each do |n|

          attrs           = n.last.dig('attrs')
          state           = attrs.dig('state')           || 0
          downtime_depth  = attrs.dig('downtime_depth')  || 0
          acknowledgement = attrs.dig('acknowledgement') || 0

          if( state == status && downtime_depth.zero? && acknowledgement.zero? )
            problems += 1
          end

        end
      end
      problems
    end

  end
end
