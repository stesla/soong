require File.join(File.dirname(__FILE__), "../vendor/gems/environment")
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'bot'

class EchoBot < Bot::Base
  highlight my_nick
  highlight "xyzzy"

  on_highlight do |source, msg|
    source.say "ECHO: #{msg}"
  end
end

EchoBot.activate(*ARGV)
