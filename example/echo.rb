require File.join(File.dirname(__FILE__), "../vendor/gems/environment")
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'bot'

class EchoBot < Bot::Base
  highlight /foo/ do |source, msg|
    source.puts msg.gsub(/foo/,'bar')
  end

  highlight proc {/^#{nick}:/} do |source, msg|
    source.puts msg
  end

  private_message do |source, msg|
    source.puts msg
  end
end

EchoBot.new(*ARGV).activate
