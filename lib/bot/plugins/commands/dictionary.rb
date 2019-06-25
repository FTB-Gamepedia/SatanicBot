require 'cinch'
require 'mw_dictionary_api'
require 'addressable/uri'
require_relative 'base_command'

module Plugins
  module Commands
    class Dictionary < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Provides a definition and examples if applicable for thee provided word. 1 arg: $dict <term>',
          plugin_name: 'dict')
      match(/dict (.+)/i)

      MAX_PUBLIC_DEFS = 4

      # @param term [String] The term to define
      # @param lexical_category [String] The lexical category of the term (e.g., noun)
      # @param definition [String] The definition straight from Oxford
      # @param example [String] An example usage of the term. Might be nil.
      # @return [String] A properly formatted and readable definition string
      def form_def(term, lexical_category, definition, example)
        str = "#{term}, #{lexical_category}: #{definition}"
        str << " | Example: #{example}" unless example.nil?

        str
      end

      # Skips ignored users, then searches the Oxford dictionary for the provided term argument. Will state so if the
      #   dictionary does not yield any results.
      # @param msg [Cinch::Message] The message object
      # @param term [String] The term for which a definition is requested
      def execute(msg, term)
        term = Addressable::URI.escape(term)

        begin
          entry_resp = LittleHelper::DICTIONARY.search(term)
        rescue MWDictionaryAPI::ResponseException => e
          msg.reply(e.message)
          return
        end

        if entry_resp.entries.empty?
          msg.reply("No results found. Suggestions: #{entry_resp.suggestions.join('; ')}")
        end

        full_defs = []
        entry_resp.entries.each do |entry|
          entry[:definitions].each do |sense|
            full_defs << form_def(entry[:word], entry[:part_of_speech], sense[:text], sense[:verbal_illustration])
          end
        end

        if msg.channel?
          full_defs.first(MAX_PUBLIC_DEFS).each { |defin| msg.reply(defin) }
          count = full_defs.count
          if count > MAX_PUBLIC_DEFS
            msg.reply("Too many results to list in public (#{count}). Sending private message to requester, #{msg.user.nick}")
            full_defs.drop(MAX_PUBLIC_DEFS).each { |defin| msg.user.send(defin) }
          end
        else
          full_defs.each { |defin| msg.reply(defin) }
        end
      end
    end
  end
end
