require 'bot/protocol'

module Bot
  module DSL
    def highlight(regexp, &block)
      block ||= proc {|source,msg|}
      highlights[regexp] << block
    end

    def highlights
      @highlights ||= Hash.new {|h,k| h[k] = []}
    end

    def private_message(&block)
      block ||= proc {|source,msg|}
      private_message_actions << block
    end

    def private_message_actions
      @private_message_actions ||= []
    end
  end

  class Base
    extend DSL

    attr_reader :nick

    def initialize(host, port, nick, channel)
      @host = host.to_s
      @port = port.to_i
      @nick = nick.to_s
      @channel = channel.to_s
      @real_name = "C-3PO"
    end

    def connect(host, port)
      EM.connect host, port, ::Bot::Protocol, self
    end

    def handle_error(protocol, error)
      $stderr.puts error.message
      $stderr.puts error.backtrace.join("\n")
      protocol.close_connection
      EM.stop
    end

    def handle_channel(source, text)
      highlights.each do |pattern, actions|
        next unless highlight_match? pattern, text
        actions.each {|action| action.call(source, text)}
      end
    end

    def handle_query(source, text)
      private_message_actions.each {|action| action.call(source, text)}
    end

    def login(protocol)
      protocol.set_nick @nick
      protocol.set_user 'bot', @real_name
      protocol.join_channel @channel
    end

    def run
      EM.run { connect @host, @port }
    end
    alias :activate :run

    private

    def highlight_match?(highlight, text)
      pattern = (highlight.kind_of? Proc) ? instance_eval(&highlight) : highlight
      pattern.match text
    end

    def highlights
      self.class.highlights
    end

    def private_message_actions
      self.class.private_message_actions
    end
  end
end
