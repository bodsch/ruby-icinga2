
# frozen_string_literal: true

module Icinga2

  #
  #
  #
  module Converts

    #
    #
    #
    def self.state_to_string( state, is_host = false )

      state =
      if( is_host == true )
        case state
        when 0
          'Up'
        when 1
          'Down'
        else
          'Undefined'
        end
      else
        case state
        when 0
          'OK'
        when 1
          'Warning'
        when 2
          'Critical'
        when 3
          'Unknown'
        else
          'Undefined'
        end
      end
      state
    end

    #
    #
    #
    def self.state_to_color( state, is_host = false )

      state =
      if( is_host == true )
        case state
        when 0
          'green'
        when 1
          'red'
        else
          'blue'
        end
      else
        case state
        when 0
          'green'
        when 1
          'yellow'
        when 2
          'red'
        when 3
          'purple'
        else
          'blue'
        end
      end
      state
    end

    #
    #
    #
    def self.format_service( name )
      service_map = name.split('!', 2)
      service_map.join( ' - ' )
    end

  end
end
