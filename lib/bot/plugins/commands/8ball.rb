require 'cinch'
require 'string-utility'

module Plugins
  module Commands
    class EightBall
      include Cinch::Plugin

      match(/8ball/i)

      DOC = 'Determines your fortune. No args'.freeze
      Variables::NonConstants.add_command('8ball', DOC)

      # Gets a random fortune and says it in chat.
      # @param msg [Cinch::Message] The message.
      def execute(msg)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        msg.reply(StringUtility.random_line(Variables::Constants::FORTUNE_PATH))
      end
    end
  end
end
