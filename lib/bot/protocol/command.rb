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
        klass = commands.detect {|klass| klass.match command, params} || self
        klass.new(protocol, prefix, command, params)
      end

      def self.commands
        @commands ||= []
      end

      def self.concrete
        Command.commands << self
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
  end
end
