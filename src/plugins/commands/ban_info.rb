require 'fishbans'
require 'cinch'

module Plugins
  module Commands
    class BanInfo
      include Cinch::Plugin

      match(/banned (.+)/i)

      doc = 'Gets whether or not the user is banned on a Minecraft server. ' \
            '1 arg: $banned <user>'
      Variables::NonConstants.add_command('banned', doc)

      # Gets Minecraft server ban information from Fishbans.
      # @param msg [Cinch::Message]
      # @param username [String] The username to check.
      def execute(msg, username)
        bans = Fishbans.get_total_bans(username)
        if bans.is_a?(Fixnum)
          if bans > 0
            message = "#{username} has been banned! What a loser! They've " \
                      "been banned #{bans} times!"
          else
            message = "#{username} has not been banned! What a gentle person!"
          end
        else
          message = "Error: #{bans}"
        end

        msg.reply(message)
      end
    end
  end
end
