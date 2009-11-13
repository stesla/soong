require 'bot/protocol/source'

module Bot
  module Protocol
    class PrivateMessage < Command
      REGEXP = /^(\S+)\s+:(.*)$/
      
      def self.match(command, params)
        'PRIVMSG' == command
      end

      attr_reader :to, :text, :source
      def after_initialize
        REGEXP.match params
        @to = $1
        @text = $2
        @source = source_klass.new(protocol, from, to)
      end

      def from
        prefix.nick
      end
    end
  end
end
