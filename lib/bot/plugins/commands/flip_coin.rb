require 'cinch'

module Plugins
  module Commands
    class FlipCoin
      include Cinch::Plugin

      COIN = %w(Tails! Heads!).freeze

      match(/flip/i)

      doc = 'Heads or tails! No args.'
      Variables::NonConstants.add_command('flip', doc)

      # Simulates a coin flip, and states randomly 'Heads!' or 'Tails!'.
      # @param msg [Cinch::Message]
      def execute(msg)
        if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          return
        end
        msg.reply(COIN.sample)
      end
    end
  end
end
