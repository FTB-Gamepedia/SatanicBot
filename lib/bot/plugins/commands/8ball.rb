require 'string-utility'
require_relative 'base_command'

module Plugins
  module Commands
    class EightBall < BaseCommand
      def initialize
        @name = :'8ball'
        @help_msg = 'Determines your fortune.'
        @usage_msg = '8ball'
      end

      # Gets a random fortune and says it in chat.
      def execute(event, *args)
        StringUtility.random_line(Variables::Constants::FORTUNE_PATH)
      end
    end
  end
end