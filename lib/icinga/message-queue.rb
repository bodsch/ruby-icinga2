
module Icinga

  module MessageQueue

    # Message-Queue Integration
    #
    #
    #
    def queue()

      c = MessageQueue::Consumer.new( @MQSettings )
#
#       threads = Array.new()

#       threads << Thread.new {

        processQueue(
          c.getJobFromTube( @mqQueue )
        )
#       }

#       threads.each { |t| t.join }

    end


    def processQueue( data = {} )

      if( data.count != 0 )

        logger.info( sprintf( 'process Message from Queue %s: %d', data.dig(:tube), data.dig(:id) ) )
        logger.debug( data )
        #logger.debug( data.dig( :body, 'payload' ) )

        command = data.dig( :body, 'cmd' )     || nil
        node    = data.dig( :body, 'node' )    || nil
        payload = data.dig( :body, 'payload' ) || nil

        if( command == nil )
          logger.error( 'wrong command' )
          logger.error( data )
          return
        end

        if( node == nil || payload == nil )
          logger.error( 'missing node or payload' )
          logger.error( data )
          return
        end

        result = {
          :status  => 400,
          :message => sprintf( 'wrong command detected: %s', command )
        }

        case command
        when 'add'
          logger.info( sprintf( 'add node %s', node ) )

          # TODO
          # check payload!
          # e.g. for 'force' ...
#           result = self.createDashboardForHost( { :host => node, :tags => tags, :overview => overview } )

#           logger.info( result )
        when 'remove'
          logger.info( sprintf( 'remove dashboards for node %s', node ) )
#           result = self.deleteDashboards( { :host => node } )

#           logger.info( result )
        when 'info'
          logger.info( sprintf( 'give dashboards for %s back', node ) )
#           result = self.listDashboards( { :host => node } )
        else
          logger.error( sprintf( 'wrong command detected: %s', command ) )

          result = {
            :status  => 400,
            :message => sprintf( 'wrong command detected: %s', command )
          }

#           logger.info( result )
        end

        result[:request]    = data

#         self.sendMessage( result )
      end

    end


    def sendMessage( data = {} )

      logger.debug( JSON.pretty_generate( data ) )

      p = MessageQueue::Producer.new( @MQSettings )

      job = {
        cmd:  'information',
        from: 'icinga',
        payload: data
      }.to_json

      logger.debug( p.addJob( 'mq-icinga', job ) )

    end


  end

end
