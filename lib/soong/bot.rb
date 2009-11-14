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

require 'soong/protocol'

module Soong
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

  class Bot
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
      EM.connect host, port, ::Soong::Protocol, self
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
      protocol.set_user 'soong', @real_name
      protocol.join_channel @channel
    end

    def run
      EM.run { connect @host, @port }
    end

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
