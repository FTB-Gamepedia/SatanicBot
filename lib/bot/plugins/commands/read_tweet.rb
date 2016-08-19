require 'cinch'

module Plugins
  module Commands
    class ReadTweet
      include Cinch::Plugin

      match(/twitter\.com\/.+\/status\/(.+)/i, use_prefix: false)

      def execute(msg, tweet_id)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        twitter = LittleHelper.init_twitter
        tweet = twitter.status(tweet_id.to_i)
        msg.reply("@#{tweet.user.screen_name} tweeted '#{tweet.text}'")
      end
    end
  end
end
