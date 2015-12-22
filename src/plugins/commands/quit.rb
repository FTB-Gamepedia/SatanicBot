require 'cinch'

module Plugins
  module Commands
    class Quit
      include Cinch::Plugin

      match(/quit/i)

      doc = 'Murders me. Owner only command. No args.'
      Variables::NonConstants.add_command('quit', doc)

      # Quits the bot if the user is authenticated as SatanicSanta.
      # @todo use bot.quit rather than exit 0 for a cleaner quit.
      def execute(msg)
        if msg.user.authname == 'SatanicSanta'
          LittleHelper.quit(msg.user.name)
        else
          msg.reply('You are not authorized for this action.')
        end
      end
    end
  end
end
