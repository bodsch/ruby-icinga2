

module Icinga2

  module Converts

    def self.stateToString( state, is_host = false )

      if( is_host == true )

        state = case state
          when 0
            'Up'
          when 1
            'Down'
          else
            'Undefined'
          end
      else

        state = case state
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

      return state

    end

    def self.stateToColor( state, is_host = false )

      if( is_host == true )

        state = case state
          when 0
            'green'
          when 1
            'red'
          else
            'blue'
          end
      else

        state = case state
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

      return state
    end

    def self.formatService( name )
      service_map = name.split('!', 2)
      service_map.join( ' - ' )
    end

  end

end
