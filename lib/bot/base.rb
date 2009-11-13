module Bot
  module DSL
    private

    attr_reader :nick

    def highlight(regexp, &block)
      block ||= proc {|source,msg|}
      highlights[regexp] << block
    end

    def highlights
      @highlights ||= Hash.new {|h,k| h[k] = []}
    end
  end

  class Base
    include DSL

    def initialize(host, port, nick, channel, &block)
      @host = host.to_s
      @port = port.to_i
      @nick = nick.to_s
      @channel = channel.to_s
      @real_name = "C-3PO"
      instance_eval(&block)
    end

    def connect(host, port)
      EM.connect host, port, ::Bot::Protocol::IRC, self
    end

    def handle_error(protocol, error)
      $stderr.puts error.message
      $stderr.puts error.backtrace.join("\n")
      protocol.close_connection
      EM.stop
    end

    def handle_message(source, text)
      highlights.each do |pattern, actions|
        next unless pattern.match text
        actions.each {|action| action.call(source, text)}
      end
    end

    def handle_notice(protocol, from, notice)
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
  end
end
  
