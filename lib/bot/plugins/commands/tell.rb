require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class Tell < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Sends a mail message to a user. 2 args: $tell <to> <message>', plugin_name: 'tell')
      match(/tell ([a-zA-Z][a-zA-Z0-9\^\-_\|\[\]]+) (.+)/)

      # Searches the relevant areas for a matching authname. First it searches the bot's known users list, then the
      # list of users in the current channel, and lastly it simply returns the provided name.
      def find_appropriate_username(msg, to)
        users_in_current_channel = msg.channel.users.keys
        name_match = lambda { |user| user.authed? && (user.authname == to || user.nick == to) }
        userlist_authname_matches = LittleHelper::BOT.user_list.select { |user| name_match.call(user) }
        channel_authname_matches = users_in_current_channel.select { |user| name_match.call(user) }
        return userlist_authname_matches[0].authname if userlist_authname_matches.any?
        return channel_authname_matches[0].authname if channel_authname_matches.any?
        to
      end

      # @param msg [Cinch::Message] The actual IRC message.
      # @param to [String] Recipient
      # @param message [String] The message to send.
      def execute(msg, to, message)
        # Check both because the authname might be empty but not nil.
        if !msg.user.authed? || msg.user.authname.empty?
          msg.reply('You must be authenticated to use the tell command.')
          return
        end
        recipient = find_appropriate_username(msg, to).downcase
        table = LittleHelper.message_table
        table.insert(to: recipient, from: msg.user.authname, msg: message, address: msg.channel.to_s, at: Time.now.xmlschema)
        msg.reply('Stored message for later.')
      end
    end
  end
end
