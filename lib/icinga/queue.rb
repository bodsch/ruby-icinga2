
module Icinga

  module Queue

    # Message-Queue Integration
    #
    #
    #
    def queue()

      c = MessageQueue::Consumer.new( @MQSettings )

      processQueue(
        c.getJobFromTube( @mqQueue )
      )
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

        when 'remove'
          logger.info( sprintf( 'remove node %s', node ) )

        when 'info'
          logger.info( sprintf( 'give informaion for %s back', node ) )

        else
          logger.error( sprintf( 'wrong command detected: %s', command ) )

          result = {
            :status  => 400,
            :message => sprintf( 'wrong command detected: %s', command )
          }

        end

        result[:request]    = data

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
