require 'cinch'

module Plugins
  module Commands
    class DeleteSentMessage
      include Cinch::Plugin

      match(/deletesent (\d+)/i)

      def execute(msg, mail_id)
        table = LittleHelper.message_table
        user = msg.user
        to_delete = table.where(id: mail_id, from: [user.nick, user.authname]).all

        if to_delete.count == 0
          msg.reply("No messages found with ID #{mail_id} sent by you")
        else to_delete[:from] == user.nick.downcase || to_delete[:from] == user.authname&.downcase
          to_delete.delete
          msg.reply("Deleted message #{mail_id}")
        end
      end
    end
  end
end
