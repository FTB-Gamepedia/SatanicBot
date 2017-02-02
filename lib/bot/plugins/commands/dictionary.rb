require 'cinch'
require 'oxford_dictionary'
require 'addressable/uri'

module Plugins
  module Commands
    class Dictionary
      include Cinch::Plugin

      match(/dict (.+)/i)

      DOC = 'Provides a definition, including examples if applicable, for the provided word. 1 required arg: $dict <term>'.freeze
      Variables::NonConstants.add_command('dict', DOC)

      MAX_PUBLIC_DEFS = 4

      # @param term [String] The term to define
      # @param lexical_category [String] The lexical category of the term (e.g., noun)
      # @param definition [String] The definition straight from Oxford
      # @param examples [Array<String>] An array of example usages of the term. Might be empty.
      # @return [String] A properly formatted and readable definition string
      def form_def(term, lexical_category, definition, examples)
        str = "#{term}, #{lexical_category}: #{definition}"
        str << " | Examples: #{examples.map(&:text).join('; ')}" unless examples.empty?

        str
      end

      # Recursive; might be slow
      # @param word [String] See #form_def
      # @param lexical_category [String] See #form_def
      # @param sense [Sense] An Oxford Sense containing all of the necessary information form a readable definition.
      #   The sense's subsenses will be recursively formed, as well.
      # @return [Array<String>] An array of properly formatted and readable definitions.
      def form_defs_from_sense(word, lexical_category, sense)
        defs = []
        sense.definitions.each do |defin|
          defs << form_def(word, lexical_category, defin, sense.examples)
        end
        sense.subsenses.each do |subsense|
          defs << form_defs_from_sense(word, lexical_category, subsense)
        end

        defs.flatten!
        defs
      end

      # Skips ignored users, then searches the Oxford dictionary for the provided term argument. Will state so if the
      #   dictionary does not yield any results.
      # @param msg [Cinch::Message] The message object
      # @param term [String] The term for which a definition is requested
      # @todo Perhaps multilingualism. Oxford allows you to provide a language code.
      def execute(msg, term)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)

        term = Addressable::URI.escape(term)

        begin
          entry_resp = LittleHelper::DICTIONARY.entry(term)
        rescue OxfordDictionary::Error => e
          msg.reply(e.message)
          return
        end

        full_defs = []
        entry_resp.lexical_entries.each do |lex|
          lex.entries.each do |entry|
            entry.senses.each do |sense|
              full_defs << form_defs_from_sense(entry_resp.word, lex.lexical_category, sense)
            end
          end
        end

        full_defs.flatten!

        if full_defs.empty?
          msg.reply('No results found, but somehow it did not error properly. Check the logs.')
        else
          full_defs.first(MAX_PUBLIC_DEFS).each { |defin| msg.reply(defin) }
          count = full_defs.count
          if count > MAX_PUBLIC_DEFS
            msg.reply("Too many results to list in public (#{count}). Sending private message to requester, #{msg.user.nick}")
            full_defs.drop(MAX_PUBLIC_DEFS).each { |defin| msg.user.send(defin) }
          end
        end
      end
    end
  end
end
