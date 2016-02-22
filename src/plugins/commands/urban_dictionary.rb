require 'cinch'
require 'urbandict'

module Plugins
  module Commands
    class UrbanDict
      include Cinch::Plugin

      match(/what does ["'](.+)["'] mean\?/i)
      set(:prefix, //)

      doc = 'Gets a definition for the word from Urban Dictionary.'
      Variables::NonConstants.add_command('urban', doc)

      def execute(msg, word)
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