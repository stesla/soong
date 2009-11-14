# Copyright (c) 2009 Samuel Tesla <samuel.tesla@gmail.com>

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'soong/protocol/commands'

module Soong
  module Protocol
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
      end
    end

    def send_line(line)
      send_data("#{line}\r\n")
    end
  end
end
