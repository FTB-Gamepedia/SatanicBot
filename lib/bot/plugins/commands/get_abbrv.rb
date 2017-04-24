require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class GetAbbreviation < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Gets either the abbreviation for the given mod, or the mod for the given abbreviation. 1 arg: $getabbrv <thing>',
          plugin_name: 'getabbrv')
      match(/getabbrv (.+)/)

      PAGE = 'Module:Mods/list'.freeze

      # @param text [String] The text to scan
      # @param standard [Regexp] The regular expression to scan as the "standard" syntax (ABBRV = {'Name'})
      # @param hyphen [Regexp] the regular expression to scan as the "hyphen" syntax (["AB-BRV"] = {'Name'})
      # @return [Array<String>] All of the matches to the two scans, combined into a single dimensional array.
      def get_matches(text, standard, hyphen)
        standard_match = text.scan(standard)
        hyphen_match = text.scan(hyphen)

        standard_match = [] unless standard_match[0]
        hyphen_match = [] unless hyphen_match[0]

        standard_match.flatten.concat(hyphen_match.flatten)
      end

      # @param mod [String] The mod name
      # @param text [String] The text in the PAGE.
      # @return [Array<String>] An array of all of the valid abbreviations for the given mod.
      def get_abbreviations(mod, text)
        get_matches(text, /\s{1,}([A-Z0-9\-]+) = {'#{mod}',/, /\s{1,}\["([A-Z0-9\-]+)"\] = {'#{mod}',/)
      end

      # @param abbreviation [String] The abbreviation
      # @param text [String] The text in the PAGE
      # @return [Array<String>] The names for the abbreviation. This should probably not be longer than 1.
      def get_names(abbreviation, text)
        get_matches(text, /\s{1,}#{abbreviation} = {'(.+)',/, /\s{1,}\["#{abbreviation}\"\] = {'(.+)',/)
      end

      # Gets either the abbreviation of a mod, or the mod using an abbreviation.
      # @param msg [Cinch::Message]
      # @param thing [String] The abbreviation OR mod.
      def execute(msg, thing)
        butt = LittleHelper.init_wiki
        module_text = butt.get_text(PAGE)
        thing.gsub!("'") { %Q{\\\\'} }

        names = get_names(thing, module_text)
        abbreviations = get_abbreviations(thing, module_text)

        thing.gsub!(%Q{\\\\'}) { "'" }
        names.map! { |val| val.gsub(%Q{\\\'}) { "'" } }

        replies = []
        replies << "#{thing} does not appear to be in the abbreviation list." if names.empty? && abbreviations.empty?
        s = names.length == 1 ? '' : 's'
        replies << "#{thing} is the abbreviation for the following mod#{s}: #{names.join(', ')}" unless names.empty?
        replies << "#{thing} is abbreviated as the following: #{abbreviations.join(', ')}" unless abbreviations.empty?

        replies.each { |str| msg.reply(str) }
      end

      def gsub_backslash_quotes!(str, opts = {})
        if opts[:reversed]
          str.gsub!("'") { %Q{\\\\'} }
        else
          str.gsub!(%Q{\\\\'}) { "'" }
        end
      end
    end
  end
end
