require 'cinch'
require_relative '../../variables'

module Plugins
  module Commands
    module Info
      class Help
        include Cinch::Plugin

        match(/help$/i, method: :help)
        match(/help (.+)/i, method: :command)

        # States the bot's command prefix character, and all of its commands.
        # @param msg [Cinch::Message]
        def help(msg)
          command_names = Variables::Constants::COMMANDS.keys.join(', ')
          msg.reply('My activation char is $.')
          msg.reply("Listing commands... #{command_names}")
        end

        # States the information for the command defined in Constants.
        # @param msg [Cinch::Message]
        # @param command [String] The command to get the info for.
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

        # States the creator of the bot, as well as the source code repository.
        # @param msg [Cinch::Message]
        def execute(msg)
          msg.reply('This bot was created by SatanicSanta, or Eli Foster: ' \
                    'https://github.com/elifoster/SatanicBot')
        end
      end
    end
  end
end
