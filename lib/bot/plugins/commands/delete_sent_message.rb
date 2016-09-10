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
        else
          deleted = table.where(id: mail_id, from: [user.nick, user.authname]).delete
          # There really should never be more than 1 message deleted, but if there is more than 1 it indicates a bug.
          msg.reply("Deleted #{deleted} message#{deleted == 1 ? '' : 's'}")
        end
      end
    end
  end
end
