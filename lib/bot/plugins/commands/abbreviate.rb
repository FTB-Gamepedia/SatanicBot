require 'cinch'
require 'array_utility'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class Abbreviate < AuthorizedCommand
      include Cinch::Plugin
      include Plugins::Wiki
      using ArrayUtility
      ignore_ignored_users

      set(help: 'Abbreviates a mod for the Tilesheet extension. Op-only. 2 args: $abbrv <abbreviation> <mod name>',
          plugin_name: 'abbrv')
      match(/abbrv ([A-Z0-9\-]+) (.+)/i)

      # Abbreviates the given mod with the given abbreviation. Fails when the
      #   mod or abbreviation are already on the list, or the user is not
      #   logged into LittleHelper. Will state the error code if there is any.
      # @param msg [Cinch::Message]
      # @param abbreviation [String] The abbreviation.
      # @param mod [String] The mod name.
      def execute(msg, abbreviation, mod)
        abbreviation = abbreviation.upcase
        mod.gsub!("'") { "\\'" }
        edit('Module:Mods/list', msg, minor: true, summary: "Adding #{mod}") do |text|
          if text =~ /[\s+]#{abbreviation} = \{\'/ || text =~ /[\s+]\["#{abbreviation}"\] = \{\'/
            next { terminate: Proc.new { 'That abbreviation is already on the list.' } }
          end
          if text.include?("= {'#{mod}',")
            next { terminate: Proc.new { 'The mod is already on the list.' } }
          end

          new_line = ' ' * 4
          if abbreviation.include?('-')
            new_line << "[\"#{abbreviation}\"]"
          else
            new_line << abbreviation
          end
          new_line << " = {'#{mod}', [=[<translate>#{mod}</translate>]=]},"
          text_ary = text.split("\n")
          text_ary.each_with_index do |line, index|
            next unless line =~ /^[\s]+[\w]+ = {'/
            ary = [new_line, line]
            next unless ary == ary.sort
            new_line.delete!(',', '') if text_ary.next(line) == '}'
            text_ary.insert(index, new_line)
            break
          end
          {
            text: text_ary.join("\n"),
            success: Proc.new { "Successfully abbreviated #{mod} as #{abbreviation}" },
            fail: Proc.new { 'Failed! There was no change to the mod list' },
            error: Proc.new { |e| "Failed! Error code: #{e.message}" },
            summary: "Adding #{mod}"
          }
        end
      end
    end
  end
end
