require_relative 'base_command'

module Plugins
  module Commands
    class Src < BaseCommand
      def initialize
        @name = :src
        @help_msg = "Outputs my creator's name and my source repository."
        @usage_msg = 'src'
      end

      # States the creator of the bot, as well as the source code repository.
      def execute(event, *args)
        'This bot was created by SatanicSanta: https://github.com/ftb-gamepedia/SatanicBot'.freeze
      end
    end
  end
end
