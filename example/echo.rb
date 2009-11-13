require File.join(File.dirname(__FILE__), "../vendor/gems/environment")
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'soong'

class EchoBot < Soong::Bot
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

EchoBot.new(*ARGV).run
