require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class Quit < OwnerCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Murders me. Owner-only. No args.', plugin_name: 'quit')
      match(/quit/i)

      # Quits the bot if the user is authenticated as the owner.
      def execute(msg)
        LittleHelper.quit(msg.user.name)
      end
    end
  end
end
