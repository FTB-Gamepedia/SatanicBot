require 'cinch'

module Plugins
  module Commands
    class Quit
      include Cinch::Plugin

      match(/quit/i)

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
