require_relative 'base_command'

module Plugins
  module Commands
    class Tweet < BaseCommand
      def initialize
        super(:tweet, 'Tweets the provided message on the bot Twitter account.', 'tweet <message>')
        @attributes[:min_args] = 1
      end

      def execute(event, args)
        tweet = args.join(' ')
        # 270 because it has to fit '[Discord '
        if tweet.length < 270
          LittleHelper::X_CLIENT.post('tweets', { text: "[Discord] #{tweet}" }.to_json)
          return 'Successfully tweeted!'.freeze
        else
          return 'That tweet is too long or too short.'.freeze
        end
      end
    end
  end
end
