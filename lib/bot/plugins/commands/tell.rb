require 'cinch'

module Plugins
  module Commands
    class Tell
      include Cinch::Plugin

      match(/tell (.+): (.+)/)

      # @param msg [Cinch::Message] The actual IRC message.
      # @param to [String] Recipient
      # @param message [String] The message to send.
      def execute(msg, to, message)
        from = msg.user.authname
        if msg.channel.has_user?(to)
          msg.reply("Hey #{to}! #{from} would like you to know that #{message}! Also, they can't read.")
        else
          table = LittleHelper.message_table
          next_id = table.map(:id).max&.+(1) || 0
          LittleHelper.message_table.insert(id: next_id, to: to, from: from, message: message)
        end
      end
    end
  end
end