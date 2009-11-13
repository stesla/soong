module Bot
  module Protocol
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

        def self.create(protocol, line)
          unless COMMAND_REGEXP.match line
            raise "bad command: #{line}"
          end
          prefix, command, params = $1 || '', $2, $3
          klass = [
            Notice,
            ChannelMessage,
            QueryMessage,
            self].detect {|klass| klass.match command, params}
          klass.new(protocol, prefix, command, params)
        end

        def self.match(command, params) true end

        def initialize(protocol, prefix, command, params)
          @protocol = protocol
          @command = command
          @params = params
          @prefix = Prefix.parse(prefix)
          after_initialize
        end

        protected

        attr_reader :params, :prefix, :protocol

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
      end

      class QueryMessage < PrivateMessage
      end

      class ChannelMessage < PrivateMessage
        def self.match(command, params)
          super(command, params) and /^#/.match params
        end
      end

      class Notice < Message
        def self.match(command, params)
          'NOTICE' == command
        end
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

      def private_message(to, msg)
        send_line "PRIVMSG #{to} :#{msg}"
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
        receive_command Command.create(self, line)
      end

      def receive_command(command)
        case command
        when ChannelMessage
          @bot.handle_channel command.source, command.text
        when QueryMessage
          @bot.handle_query command.source, command.text
        when Notice
          @bot.handle_notice self, command.from, command.text
        end
      end

      def send_line(line)
        send_data("#{line}\r\n")
      end
  end
end
