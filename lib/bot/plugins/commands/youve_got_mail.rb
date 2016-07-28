require 'cinch'

module Plugins
  module Commands
    class YouveGotMail
      include Cinch::Plugin

      # Match anything but messages containing checkmail.
      match(/^(?!.*checkmail).*/i, use_prefix: false)

      # @param msg [Cinch::Message]
      def execute(msg)
        table = LittleHelper.message_table
        user = msg.user
        nick = user.nick
        nick_dc = nick.downcase
        auth = user.authname&.downcase
        count = table.where(to: [nick_dc, auth]).count
        if count > 0
          msg.channel.send("#{nick}: You've got mail (#{count} unread)! Use the checkmail command to check your mail!")
        end
      end
    end
  end
end
