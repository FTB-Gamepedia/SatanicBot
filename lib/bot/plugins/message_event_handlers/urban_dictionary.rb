require 'urbandict'
require_relative 'base_meh'

module Plugins
  module MessageEventHandlers
    class UrbanDict < BaseMEH
      def initialize
        super(contains: /what does (["'])[^"']+\1 mean\?/i)
      end

      CACHE = {}

      def execute(event)
        validate_cache(event.author)

        word = event.message.content.match(/what does (["'])([^"']+)\1 mean\?/i)[2]
        begin
          slangs = UrbanDictionary.define(word)
        rescue UrbanDictionary::UrbanDictError => e
          return e.message
        end
        return "That's a good question, #{event.author.mention}" if slangs.empty?
        chosen = nil
        slangs.each do |slang|
          chosen = slang unless in_cache?(event.author, slang)
        end
        if chosen
          cache_definition(event.author, chosen)
          return "Well, #{event.author.mention}, according to #{chosen.author}, it means '#{chosen.definition}'"
        else
          return "#{event.author.mention}, you have exhausted all definitions for '#{word}'."
        end
      end

      # @param user [Discordrb::User]
      # @param slang [Slang]
      def cache_definition(user, slang)
        CACHE[user.id] << slang.id
      end

      # @param user [Discordrb::User]
      # @param slang [Slang]
      def in_cache?(user, slang)
        CACHE[user.id].include?(slang.id)
      end

      # @param user [Discordrb::User]
      def validate_cache(user)
        CACHE[user.id] = [] unless CACHE.include?(user.id)
      end
    end
  end
end
