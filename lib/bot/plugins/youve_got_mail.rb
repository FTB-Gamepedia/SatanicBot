require 'cinch'

module Plugins
  class YouveGotMail
    include Cinch::Plugin

    listen_to(:join, method: :execute)

    # @param msg [Cinch::Message]
    def execute(msg)
      table = LittleHelper.message_table
      user = msg.user
      if table.where(to: [user.nick, user.authname]).count > 0
        msg.channel.send("#{msg.user.nick}: You've got mail! Use the checkmail command to check your mail!")
      end
    end
  end
end