require 'cinch'

module Plugins
  module Commands
    class FlipCoin
      include Cinch::Plugin

      match(/flip/i)

      def execute(msg)
        coin = ['Tails!', 'Heads!'].sample
        msg.reply(coin)
      end
    end
  end
end
