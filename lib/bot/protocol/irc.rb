module Bot
  module Protocol
    module IRC
      MaxLineLength = 512

      def initialize(bot)
        @bot = bot
        @buffer = BufferedTokenizer.new("\n", MaxLineLength)
      end

      # EventMachine::Connection
      
      def connection_completed
        @bot.login(self)
      end

      def receive_data(data)
        @buffer.extract(data).each {|line| receive_line line.chomp}
      rescue => error
        receive_error error
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

      def receive_error(error)
        @bot.handle_error error
      end

      def receive_line(line)
        puts "GOT: #{line}"
      end

      def send_line(line)
        send_data("#{line}\r\n")
      end
    end
  end
end
