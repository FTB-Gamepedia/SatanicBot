require 'cinch'
require 'string-utility'
require_relative 'base_command'

module Plugins
  module Commands
    class EightBall < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      match(/8ball/i)

      DOC = 'Determines your fortune. No args'.freeze
      Variables::NonConstants.add_command('8ball', DOC)

      # Gets a random fortune and says it in chat.
      # @param msg [Cinch::Message] The message.
      def execute(msg)
        msg.reply(StringUtility.random_line(Variables::Constants::FORTUNE_PATH))
      end
    end
  end
end
