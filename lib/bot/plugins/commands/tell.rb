require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class Tell < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Sends a mail message to a user. 2 args: $tell <to> <message>', plugin_name: 'tell')
      match(/tell ([a-zA-Z][a-zA-Z0-9\^\-_\|\[\]]+) (.+)/)

      # @param msg [Cinch::Message] The actual IRC message.
      # @param to [String] Recipient
      # @param message [String] The message to send.
      def execute(msg, to, message)
        # Check both because the authname might be empty but not nil.
        authed = msg.user.authed? && !msg.user.authname.empty?
        from = authed ? msg.user.authname : msg.user.nick
        recipient = to.downcase
        table = LittleHelper.message_table
        table.insert(to: recipient, from: from, msg: message)
        msg.reply('Stored message for later.')
      end
    end
  end
end
