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

module Soong
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
