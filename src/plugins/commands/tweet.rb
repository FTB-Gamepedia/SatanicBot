require 'cinch'

module Plugins
  module Commands
    class Tweet
      include Cinch::Plugin

      match(/tweet (.+)/i)

      doc = 'Creates a new tweet on the LittleHelperBot Twitter account. ' \
            '1 arg: $tweet <message>'
      Variables::NonConstants.add_command('tweet', doc)

      # Tweets the message provided.
      # @param msg [Cinch::Message]
      # @param tweet [String] The message to tweet.
      def execute(msg, tweet)
        # 134 because it has to fit "[IRC] "
        if tweet.length > 1 && tweet.length < 134
          twitter = LittleHelper.init_twitter
          twitter.update("[IRC] #{tweet}")
          msg.reply('Successfully tweeted!'.freeze)
        else
          msg.reply('That tweet is either too long or too short.'.freeze)
        end
      end
    end
  end
end
