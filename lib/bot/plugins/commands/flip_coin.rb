require_relative 'base_command'

module Plugins
  module Commands
    class FlipCoin < BaseCommand
      def initialize
        @name = :flip
        @help_msg = 'Heads or tails! No args.'
        @usage_msg = 'flip'
      end

      COIN = %w(Tails! Heads!).freeze

      # Simulates a coin flip, and states randomly 'Heads!' or 'Tails!'.
      def execute(event, *args)
        COIN.sample
      end
    end
  end
end
