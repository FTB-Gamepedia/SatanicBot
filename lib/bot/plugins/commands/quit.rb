require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class Quit < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      match(/quit/i)

      DOC = 'Murders me. Owner only command. No args.'.freeze
      Variables::NonConstants.add_command('quit', DOC)

      # Quits the bot if the user is authenticated as the owner.
      def execute(msg)
        if msg.user.authname == Variables::Constants::OWNER
          LittleHelper.quit(msg.user.name)
        else
          msg.reply(Variables::Constants::OWNER_ONLY)
        end
      end
    end
  end
end
