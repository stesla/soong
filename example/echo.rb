require File.join(File.dirname(__FILE__), "../vendor/gems/environment")
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'bot'

bot = Bot::Base.new(*ARGV) do
  highlight /^#{nick}:/ do |source, msg|
    source.puts "ECHO: #{msg}"
  end

  private_message do |source, msg|
    source.puts "WHISPER: #{msg}"
  end
end

bot.activate
