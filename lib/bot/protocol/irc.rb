module Bot
  module Protocol
    module IRC
      class Prefix
        PREFIX_REGEXP = /^:([^!]+)!.*$/

        def self.parse(prefix)
          PREFIX_REGEXP.match prefix
          new($1)
        end

        attr_reader :nick

        def initialize(nick)
          @nick = nick || ''
        end
      end

      class Command
        COMMAND_REGEXP = /^(:\S+\s+)?(\S+)\s+(.*)$/

        def self.create(line)
          unless COMMAND_REGEXP.match line
            raise "Malformatted command: #{line}"
          end
          prefix, command, params = $1 || '', $2, $3
          klass = case command
                  when 'PRIVMSG' then PrivateMessage
                  when 'NOTICE' then Notice
                  else self
                  end
          klass.new(prefix, command, params)
        end

        def initialize(prefix, command, params)
          @command = command
          @params = params
          @prefix = Prefix.parse(prefix)
          after_initialize
        end

        protected

        attr_reader :params, :prefix

        def after_initialize; end
      end

      class Message < Command
        def from
          prefix.nick
        end

        def text
          params
        end
      end

      class PrivateMessage < Message
        REGEXP = /^(\S+)\s+:(.*)$/

        attr_reader :to, :text
        def after_initialize
          REGEXP.match params
          @to = $1
          @text = $2
        end
      end

      class Notice < Message
      end

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
        @bot.handle_error self, error
      end

      def receive_line(line)
        receive_command Command.create(line)
      end

      def receive_command(command)
        case command
        when PrivateMessage
          @bot.handle_message command.from, command.to, command.text
        when Notice
          @bot.handle_notice command.from, command.text
        else
          p command
        end
      end

      def send_line(line)
        send_data("#{line}\r\n")
      end
    end
  end
end
