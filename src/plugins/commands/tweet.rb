require 'cinch'
require_relative '../../generalutils'

module Plugins
  module Commands
    class Tweet
      include Cinch::Plugin

      match(/tweet (.+)/i)

      def execute(msg, tweet)
        # 134 because it has to fit "[IRC] "
        if tweet.length > 1 && tweet.length < 134
          LittleHelper.tweet("[IRC] #{tweet}")
          msg.reply('Successfully tweeted!')
        else
          msg.reply('That tweet is either too long or too short.')
        end
      end
    end
  end
end
