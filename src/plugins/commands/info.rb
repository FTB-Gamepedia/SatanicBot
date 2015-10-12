require 'cinch'

module Plugins
  module Commands
    module Info
      class Help
        include Cinch::Plugin

        match /help/i

        def execute(msg)
          command_names = $commands.keys.join(', ')
          msg.reply("My activation char is $. Listing commands... " \
                    "#{command_names}")
        end
      end

      class Src
        include Cinch::Plugin

        match /src/i

        def execute(msg)
          msg.reply('This bot was created by SatanicSanta, or Eli Foster: ' \
                    'https://github.com/elifoster/SatanicBot')
        end
      end

      class Command
        include Cinch::Plugin

        match /command (.+)/i

        def execute(msg, command)
          if $commands.keys.include? command
            msg.reply("Command: #{command}. Info: #{$commands[command]}")
          end
        end
      end
    end
  end
end
