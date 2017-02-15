require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class Tweet < BaseCommand
      include Cinch::Plugin

      set(help: 'Tweets the provided message on the bot Twitter account. 1 arg: $tweet <message>', plugin_name: 'tweet')
      match(/tweet (.+)/i)

      # Tweets the message provided.
      # @param msg [Cinch::Message]
      # @param tweet [String] The message to tweet.
      def execute(msg, tweet)
        # 134 because it has to fit "[IRC] "
        if tweet.length > 1 && tweet.length < 134
          LittleHelper::TWEETER.update("[IRC] #{tweet}")
          msg.reply('Successfully tweeted!'.freeze)
        else
          msg.reply('That tweet is either too long or too short.'.freeze)
        end
      end
    end
  end
end
