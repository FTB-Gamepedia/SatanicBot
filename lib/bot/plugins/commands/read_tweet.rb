require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class ReadTweet < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      match(/twitter\.com\/.+\/status\/(.+)/i, use_prefix: false)

      def execute(msg, tweet_id)
        tweet = LittleHelper::TWEETER.status(tweet_id.to_i)
        msg.reply("@#{tweet.user.screen_name} tweeted '#{tweet.text}'")
      end
    end
  end
end
