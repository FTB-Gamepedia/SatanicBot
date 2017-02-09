require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class CleverBot < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      match(/^(.+): (.+)/i, use_prefix: false)

      DOC = 'Talk with me by mentioning me as normal (LittleHelper: <message>)'.freeze
      Variables::NonConstants.add_command('cleverbot', DOC)

      def execute(msg, username, talk)
        return unless username.casecmp(bot.nick).zero?
        msg.reply("#{msg.user.nick}: #{LittleHelper::CLEVER.say(talk)}")
      end
    end
  end
end
