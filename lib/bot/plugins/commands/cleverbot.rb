require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class CleverBot < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Talk with me by mentioning me as normal (LittleHelper: <message>', plugin_name: 'cleverbot')
      match(/^(.+): (.+)/i, use_prefix: false)

      def execute(msg, username, talk)
        return unless username.casecmp(bot.nick).zero?
        msg.reply("#{msg.user.nick}: #{LittleHelper::CLEVER.say(talk)}")
      end
    end
  end
end
