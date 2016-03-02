require 'cinch'

module Plugins
  module Commands
    class FlipCoin
      include Cinch::Plugin

      match(/flip/i)

      DOC = 'Heads or tails! No args.'.freeze
      Variables::NonConstants.add_command('flip', DOC)

      COIN = %w(Tails! Heads!).freeze

      # Simulates a coin flip, and states randomly 'Heads!' or 'Tails!'.
      # @param msg [Cinch::Message]
      def execute(msg)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        msg.reply(COIN.sample)
      end
    end
  end
end
