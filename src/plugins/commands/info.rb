require 'cinch'
require_relative '../../variables'

module Plugins
  module Commands
    module Info
      class Help
        include Cinch::Plugin

        match /help/i

        def execute(msg)
          command_names = Variables::Constants::COMMANDS.keys.join(', ')
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
          if Variables::Constants::COMMANDS.keys.include? command
            command_info = Variables::Constants::COMMANDS[command]
            msg.reply("Command: #{command}. Info: #{command_info}")
          end
        end
      end
    end
  end
end
