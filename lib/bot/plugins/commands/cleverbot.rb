require 'cinch'

module Plugins
  module Commands
    class CleverBot
      include Cinch::Plugin

      # TODO: Figure out a way to call LittleHelper::BOT.nick here for modularity.
      match(/^LittleHelper: (.+)/i, use_prefix: false)

      DOC = 'Talk with me by mentioning me as normal (LittleHelper: <message>)'.freeze
      Variables::NonConstants.add_command('cleverbot', DOC)

      def execute(msg, talk)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        msg.reply("#{msg.user.nick}: #{LittleHelper.clever.say(talk)}")
      end
    end
  end
end
