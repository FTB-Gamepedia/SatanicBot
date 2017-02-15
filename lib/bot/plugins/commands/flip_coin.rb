require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class FlipCoin < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Heads or tails! No args.', plugin_name: 'flip')
      match(/flip/i)

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
