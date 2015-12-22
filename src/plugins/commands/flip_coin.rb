require 'cinch'

module Plugins
  module Commands
    class FlipCoin
      include Cinch::Plugin

      match(/flip/i)

      doc = 'Heads or tails! No args.'
      Variables::NonConstants.add_command('flip', doc)

      # Simulates a coin flip, and states randomly 'Heads!' or 'Tails!'.
      # @param msg [Cinch::Message]
      def execute(msg)
        coin = ['Tails!', 'Heads!'].sample
        msg.reply(coin)
      end
    end
  end
end
