require 'cinch'
require_relative '../../variables'

module Plugins
  module Commands
    module Info
      class Help
        include Cinch::Plugin

        match(/help$/i, method: :help)
        match(/help (.+)/i, method: :command)

        DOC = 'Gets basic usage information on the bot. ' \
              '1 optional arg: $help <command> to get info on a command.'.freeze
        Variables::NonConstants.add_command('help', DOC)

        # States the bot's command prefix character, and all of its commands.
        # @param msg [Cinch::Message]
        def help(msg)
          return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          command_names = Variables::NonConstants.get_commands.keys.join(', ').freeze
          msg.reply("Listing commands... #{command_names}".freeze)
        end

        # States the information for the command defined in Constants.
        # @param msg [Cinch::Message]
        # @param command [String] The command to get the info for.
        def command(msg, command)
          if Variables::NonConstants.get_commands.keys.include? command
            command_info = Variables::NonConstants.get_commands[command]
            msg.reply("Command: #{command}. Info: #{command_info}")
          else
            msg.reply('That is not a command.'.freeze)
          end
        end
      end

      class Src
        include Cinch::Plugin

        match(/src/i)

        DOC = "Outputs my creator's name and my repository.".freeze
        Variables::NonConstants.add_command('src', DOC)

        # States the creator of the bot, as well as the source code repository.
        # @param msg [Cinch::Message]
        def execute(msg)
          return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          msg.reply('This bot was created by SatanicSanta, or Eli Foster: ' \
                    'https://github.com/ftb-gamepedia/SatanicBot'.freeze)
        end
      end
    end
  end
end
