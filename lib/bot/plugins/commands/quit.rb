require 'cinch'

module Plugins
  module Commands
    class Quit
      include Cinch::Plugin

      match(/quit/i)

      doc = 'Murders me. Owner only command. No args.'
      Variables::NonConstants.add_command('quit', doc)

      # Quits the bot if the user is authenticated as the owner.
      def execute(msg)
        if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          return
        end
        if msg.user.authname == Variables::Constants::OWNER
          LittleHelper.quit(msg.user.name)
        else
          msg.reply(Variables::Constants::OWNER_ONLY)
        end
      end
    end
  end
end
