require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    module Info
      class Help < BaseCommand
        include Cinch::Plugin
        ignore_ignored_users

        # $help <command. is handled by Cinch itself using the `set` stuff.
        set(help: 'Gets basic usage information on the bot. 1 optional arg: $help <command> to get info on a specific command',
            plugin_name: 'help')
        match(/help$/i)

        # States the bot's command prefix character, and all of its commands.
        # @param msg [Cinch::Message]
        def execute(msg)
          command_names = LittleHelper::BOT.plugins.map { |plugin| plugin.class.plugin_name }.sort.join(', ').freeze
          msg.reply("Listing commands... #{command_names}".freeze)
        end
      end

      class Src < BaseCommand
        include Cinch::Plugin
        ignore_ignored_users

        set(help: "Outputs my creator's name and my source repository.", plugin_name: 'src')
        match(/src/i)


        # States the creator of the bot, as well as the source code repository.
        # @param msg [Cinch::Message]
        def execute(msg)
          msg.reply('This bot was created by SatanicSanta, or Eli Foster: ' \
                    'https://github.com/ftb-gamepedia/SatanicBot'.freeze)
        end
      end
    end
  end
end
