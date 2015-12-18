require 'cinch'

module Plugins
  module Commands
    class Quit
      include Cinch::Plugin

      match(/quit/i)

      # Quits the bot if the user is authenticated as SatanicSanta.
      # @todo use bot.quit rather than exit 0 for a cleaner quit.
      def execute(msg)
        if msg.user.authname == 'SatanicSanta'
          exit 0
        else
          msg.reply('You are not authorized for this action.')
        end
      end
    end
  end
end
