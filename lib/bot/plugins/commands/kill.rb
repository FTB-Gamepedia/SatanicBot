require_relative 'base_command'

module Plugins
  module Commands
    class Kill < OwnerCommand
      def initialize
        super(:kill, 'Murders me. Owner-only.')
      end

      # Quits the bot if the user is the owner.
      def execute(event, args)
        event.send_message("I will be avenged, #{event.author.mention}")
        LittleHelper::BOT.stop
      end
    end
  end
end
