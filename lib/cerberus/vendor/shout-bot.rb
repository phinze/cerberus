=begin
ShoutBot
  Ridiculously simple library to quickly say something on IRC
  <http://github.com/sr/shout-bot>

EXAMPLE

  ShoutBot.shout('irc://irc.freenode.net:6667/github', :as => "ShoutBot") do |channel|
    channel.say "check me out! http://github.com/sr/shout-bot"
  end

LICENSE

             DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                     Version 2, December 2004

  Copyright (C) 2008 Simon Rozet <http://purl.org/net/sr/>
  Copyright (C) 2008 Harry Vangberg <http://trueaffection.net>

  Everyone is permitted to copy and distribute verbatim or modified
  copies of this license document, and changing it is allowed as long
  as the name is changed.

             DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

   0. You just DO WHAT THE FUCK YOU WANT TO.
=end

require "addressable/uri"
require "socket"

class ShoutBot
  def self.shout(uri, options={}, &block)
    raise ArgumentError unless block_given?

    uri = Addressable::URI.parse(uri)
    irc = new(uri.host, uri.port, options.delete(:as)) do |irc|
      irc.join(uri.path[1..-1], &block)
    end
  end

  def initialize(server, port, nick)
    raise ArgumentError unless block_given?

    @socket = TCPSocket.open(server, port)
    @socket.puts "NICK #{nick}"
    @socket.puts "USER #{nick} #{nick} #{nick} :#{nick}"
    sleep 1
    yield self
    @socket.puts "QUIT"
    @socket.gets until @socket.eof?
  end

  def join(channel)
    raise ArgumentError unless block_given?

    @channel = "##{channel}"
    @socket.puts "JOIN #{@channel}"
    yield self
    @socket.puts "PART #{@channel}"
  end

  def say(message)
    return unless @channel
    @socket.puts "PRIVMSG #{@channel} :#{message}"
  end
end
