require 'bot/protocol/commands/private_message'

module Bot
  module Protocol
    class ChannelMessage < PrivateMessage
      concrete

      class ChannelSource < Protocol::Source
        def reply_to() to end
      end

      def self.match(command, params)
        super(command, params) and /^#/.match params
      end

      def source_klass() ChannelSource end
    end
  end
end
