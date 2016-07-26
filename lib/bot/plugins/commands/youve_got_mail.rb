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
        msg.channel.send("#{nick}: You've got mail! Use the checkmail command to check your mail!") if table.where(to: [nick_dc, auth]).count > 0
      end
    end
  end
end
