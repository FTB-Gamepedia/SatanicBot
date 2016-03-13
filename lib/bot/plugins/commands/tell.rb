require 'cinch'

module Plugins
  module Commands
    class Tell
      include Cinch::Plugin

      match(/tell (.+): (.+)/)

      DOC = 'Sends a message to a user that is not here. 2 args: $tell <to>: <message>'.freeze
      Variables::NonConstants.add_command('tell', DOC)

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
          table.insert(id: next_id, to: to, from: from, message: message)
          msg.reply('Stored message for later.')
        end
      end
    end
  end
end