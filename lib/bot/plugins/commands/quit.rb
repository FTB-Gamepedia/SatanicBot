require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class Quit < OwnerCommand
      include Cinch::Plugin
      ignore_ignored_users

      match(/quit/i)

      DOC = 'Murders me. Owner only command. No args.'.freeze
      Variables::NonConstants.add_command('quit', DOC)

      # Quits the bot if the user is authenticated as the owner.
      def execute(msg)
        LittleHelper.quit(msg.user.name)
      end
    end
  end
end
