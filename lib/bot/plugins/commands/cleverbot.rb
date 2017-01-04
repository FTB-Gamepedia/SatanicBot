require 'cinch'

module Plugins
  module Commands
    class CleverBot
      include Cinch::Plugin

      match(/^(.+): (.+)/i, use_prefix: false)

      DOC = 'Talk with me by mentioning me as normal (LittleHelper: <message>)'.freeze
      Variables::NonConstants.add_command('cleverbot', DOC)

      def execute(msg, username, talk)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        return unless username.casecmp(bot.nick).zero?
        msg.reply("#{msg.user.nick}: #{LittleHelper::CLEVER.say(talk)}")
      end
    end
  end
end
