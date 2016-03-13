require 'cinch'

module Plugins
  module Commands
    class CheckMail
      include Cinch::Plugin

      match(/checkmail/)

      # @param msg [Cinch::Message]
      def execute(msg)
        table = LittleHelper.message_table
        their_messages = []
        table.all.each do |hash|
          their_messages << hash if hash[:to] == msg.user.authname || hash[:to] == msg.user.nick
        end

        msg.reply("You have #{their_messages.length} unread messages. Reading...")
        deleted = 0
        their_messages.each do |hash|
          msg.reply("#{msg.user.nick}: #{hash[:from]} says \"#{hash[:msg]}\"")
          deleted += table.where('id = ?', hash[:id]).delete
        end
        msg.reply("Finished reading unread messages. Deleted #{deleted} messages.")
      end
    end
  end
end