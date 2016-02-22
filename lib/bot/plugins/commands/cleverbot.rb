require 'cinch'

module Plugins
  module Commands
    class CleverBot
      include Cinch::Plugin

      # TODO: Figure out a way to call LittleHelper::BOT.nick here for modularity.
      match(/LittleHelper: (.+)/i, use_prefix: false)

      doc = 'Talk with me, by mentioning me as normal (LittleHelper: <message>)'
      Variables::NonConstants.add_command('cleverbot', doc)

      def execute(msg, talk)
        msg.reply("#{msg.user.nick}: #{LittleHelper.clever.say(talk)}")
      end
    end
  end
end