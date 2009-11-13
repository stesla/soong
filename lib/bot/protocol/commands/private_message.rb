module Bot
  module Protocol
    class PrivateMessage < Command
      REGEXP = /^(\S+)\s+:(.*)$/
      
      class Source
        def initialize(protocol, from, to)
          @protocol = protocol
          @reply_to = (to.index('#') == 0) ? to : from
        end

        def puts(msg)
          @protocol.private_message @reply_to, msg
        end
      end

      def self.match(command, params)
        'PRIVMSG' == command
      end

      attr_reader :to, :text, :source
      def after_initialize
        REGEXP.match params
        @to = $1
        @text = $2
        @source = Source.new(protocol, from, to)
      end

      def from
        prefix.nick
      end
    end
  end
end
