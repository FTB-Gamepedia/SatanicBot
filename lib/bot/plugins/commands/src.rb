require_relative 'base_command'

module Plugins
  module Commands
    class Src < BaseCommand
      def initialize
        super(:src, "Outputs my creator's name and my source repository.")
      end

      # States the creator of the bot, as well as the source code repository.
      def execute(event, *args)
        'This bot was created by SatanicSanta: https://github.com/ftb-gamepedia/SatanicBot'.freeze
      end
    end
  end
end
