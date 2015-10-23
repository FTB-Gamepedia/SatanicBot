require 'cinch'
require_relative '../../variables'

module Plugins
  module Commands
    module Info
      class Help
        include Cinch::Plugin

        match(/help$/i, method: :help)
        match(/help (.+)/i, method: :command)

        def help(msg)
          command_names = Variables::Constants::COMMANDS.keys.join(', ')
          msg.reply('My activation char is $.')
          msg.reply("Listing commands... #{command_names}")
        end

        def command(msg, command)
          if Variables::Constants::COMMANDS.keys.include? command
            command_info = Variables::Constants::COMMANDS[command]
            msg.reply("Command: #{command}. Info: #{command_info}")
          else
            msg.reply('That is not a command.')
          end
        end
      end

      class Src
        include Cinch::Plugin

        match(/src/i)

        def execute(msg)
          msg.reply('This bot was created by SatanicSanta, or Eli Foster: ' \
                    'https://github.com/elifoster/SatanicBot')
        end
      end
    end
  end
end
