
# frozen_string_literal: true

module Icinga2

  # many convert functions
  #
  #
  module Converts

    HOST_STATE_STRING = %w[Up Down].freeze
    SERVICE_STATE_STRING = %w[OK Warning Critical Unknown].freeze

    HOST_STATE_COLOR = %w[green red].freeze
    SERVICE_STATE_COLOR = %w[green yellow red purple].freeze

    # convert a Icinga2 state into a human readable state
    #
    # @param [String] state the Icinga2 State
    # @param [Bool] is_host (false) if this a Host or a Service Check
    #
    # @return [String]
    #
    def state_to_string( state, is_host = false )

      result = SERVICE_STATE_STRING[state] if( is_host == false )
      result = HOST_STATE_STRING[state] if( is_host == true )
      result = 'Undefined' if( result.nil? )
      result
    end

    # convert a Icinga2 state into a named color
    #
    # @param [String] state the Icinga2 State
    # @param [Bool] is_host (false) if this a Host or a Service Check
    #
    # @return [String]
    #
    def state_to_color( state, is_host = false )

      result = SERVICE_STATE_COLOR[state] if( is_host == false )
      result = HOST_STATE_COLOR[state] if( is_host == true )
      result = 'blue' if( result.nil? )
      result
    end

    # reformat a service check name
    #
    # @param [String] name
    #
    # @return [String]
    #
    def self.format_service( name )
      service_map = name.split('!', 2)
      service_map.join( ' - ' )
    end

  end
end
