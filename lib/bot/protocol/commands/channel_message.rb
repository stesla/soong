require 'bot/protocol/commands/private_message'

module Bot
  module Protocol
    class ChannelMessage < PrivateMessage
      concrete
      def self.match(command, params)
        super(command, params) and /^#/.match params
      end
    end
  end
end
