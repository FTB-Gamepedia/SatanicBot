require 'cinch'
require 'urbandict'

module Plugins
  module Commands
    class UrbanDict
      include Cinch::Plugin

      match(/what does ["'](.+)["'] mean\?/i)
      set(:prefix, //)

      DOC = 'Gets a definition for the word from Urban Dictionary.'.freeze
      Variables::NonConstants.add_command('urban', DOC)

      def execute(msg, word)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        slangs = UrbanDictionary.define(word)
        if slangs.empty?
          msg.reply("That's a good question, #{msg.user.nick}.")
        else
          chosen = slangs.sample
          msg.reply("Well, #{msg.user.nick}, according to #{chosen.author}, it means '#{chosen.definition}'")
        end
      end
    end
  end
end
