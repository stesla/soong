module Bot
  module Protocol
    module IRC
      def initialize(bot)
        @bot = bot
      end

      # EventMachine::Connection
      
      def connection_completed
        @bot.login(self)
      end

      def receive_data(data)
        puts "GOT: #{data}"
      end

      # IRC Stuff

      def join_channel(channel, key='')
        send_line "JOIN #{channel} #{key}"
      end
      
      def set_nick(nick)
        send_line "NICK #{nick}"
      end

      def set_user(user, real_name)
        send_line "USER #{user} . . :#{real_name}"
      end
      
      private

      def send_line(line)
        send_data("#{line}\r\n")
      end
    end
  end
end
