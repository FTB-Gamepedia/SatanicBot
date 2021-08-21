require 'cinch'
require 'urbandict'
require_relative 'base_command'

module Plugins
  module Commands
    class UrbanDict < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      match(/what does (["'])([^"']*)\1 mean\?/i, use_prefix: false)
      set(help: 'Gets a definition for the word from Urban Dictionary.', plugin_name: 'urban')

      CACHE = {}

      def execute(msg, _, word)
        validate_cache(msg.user)
        begin
          slangs = UrbanDictionary.define(word)
        rescue UrbanDictionary::UrbanDictError => e
          msg.reply(e.message)
          return
        end
        if slangs.empty?
          msg.reply("That's a good question, #{msg.user.nick}.")
        else
          chosen = nil
          slangs.each do |slang|
            chosen = slang unless in_cache?(msg.user, slang)
          end
          if chosen
            msg.reply("Well, #{msg.user.nick}, according to #{chosen.author}, it means '#{chosen.definition}'")
            cache_definition(msg.user, chosen)
          else
            msg.reply("#{msg.user.nick}, you have exhausted all definitions for '#{word}'.")
          end
        end
      end

      # @param user [User]
      # @param slang [Slang]
      def cache_definition(user, slang)
        CACHE[user.nick] << slang.id
      end

      # @param user [User]
      # @param slang [Slang]
      def in_cache?(user, slang)
        CACHE[user.nick].include?(slang.id)
      end

      # @param user [User]
      def validate_cache(user)
        CACHE[user.nick] = [] unless CACHE.key?(user.nick)
      end
    end
  end
end
