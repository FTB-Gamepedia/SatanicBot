require 'cinch'

module Plugins
  module Commands
    class GetSentMessages
      include Cinch::Plugin

      match(/getsent/i)

      def execute(msg)
        table = LittleHelper.message_table
        user = msg.user
        outgoing_messages = table.where(from: [user.nick, user.authname]).all
        if outgoing_messages.count < 1
          user.send('You have not sent any messages.')
          return
        end

        outgoing_messages.each do |message|
          user.send("Message ID #{message[:id]} to #{message[:to]}: #{message[:msg]}")
        end
      end
    end
  end
end