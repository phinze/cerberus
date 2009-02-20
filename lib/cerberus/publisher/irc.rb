require 'rubygems'
require 'cerberus/publisher/base'
require 'cerberus/vendor/shout-bot'

class Cerberus::Publisher::IRC < Cerberus::Publisher::Base
  def self.publish(state, manager, options)
    irc_options = options[:publisher, :irc]
    raise "There is no channel provided for IRC publisher" unless irc_options[:channel]
    subject,body = Cerberus::Publisher::Base.formatted_message(state, manager, options)
    message = subject + "\n" + '*' * subject.length

    nick = irc_options[:nick] || 'CerberusBot'
    port = irc_options[:port] || 6667
    uri = "irc://#{irc_options[:server]}:#{port}/#{irc_options[:channel]}"

    silence_stream(STDOUT) do
      ShoutBot.shout( uri, :as => nick ) do |channel|
        message.split("\n").each { |line| channel.say( line ) }
      end
    end

  end
end
# http://github.com/sr/integrity-irc/blob/2ab5c3b4e865614204d2af41daf4c4bf2c20b3ab/lib/notifier/irc.rb
