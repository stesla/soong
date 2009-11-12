module Bot
  module DSL
    def my_nick
    end

    def highlight(string)
    end

    def on_highlight(&block)
    end
  end
  
  class Base
    extend DSL

    def self.activate(*args)
      bot = new(*args)
      bot.run
    end

    def initialize(host, port, nick, channel)
      @host = host.to_s
      @port = port.to_i
      @nick = nick.to_s
      @channel = channel.to_s
      @real_name = "C-3PO"
    end

    def connect(host, port)
      EM.connect host, port, ::Bot::Protocol::IRC, self
    end

    def handle_error(protocol, error)
      $stderr.puts error.message
      protocol.close_connection
      EM.stop
    end

    def login(protocol)
      protocol.set_nick @nick
      protocol.set_user 'bot', @real_name
      protocol.join_channel @channel
    end

    def run
      EM.run { connect @host, @port }
    end
  end
end
  
