require 'array_utility'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class Abbreviate < AuthorizedCommand
      include Plugins::Wiki
      using ArrayUtility

      # Captures the abbreviation in either the standard or the ["ABBRV"] format as
      #   used on Module:Mods/list.
      ABBRV_CAPTURE_REGEX = /^[\s]{4}(?:\[")?([\w-]+)(?:"\])? = {'/

      def initialize
        super(:abbrv, 'Abbreviates a mod for the Tilesheets extension.', 'abbrv <abbreviation> <mod name>')
        @attributes[:min_args] = 2
      end

      # match(/abbrv ([A-Z0-9\-]+) (.+)/i)

      # Abbreviates the given mod with the given abbreviation. Fails when the
      #   mod or abbreviation are already on the list, or the user is not
      #   logged into LittleHelper. Will state the error code if there is any.
      # @param event [Discordrb::Events::CommandEvent]
      # @param args [Array<String>]
      def execute(event, args)
        abbreviation = args[0].upcase
        puts abbreviation
        return 'Invalid mod abbreviation.' if abbreviation !~ /[\w\-]+/
        mod = args[1..-1].join(' ')
        escaped_mod = mod.gsub("'") { "\\'" }
        edit('Module:Mods/list', event, minor: true, summary: "Adding #{mod}") do |text|
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
          new_line << " = {'#{escaped_mod}', [=[<translate>#{mod}</translate>]=]},"
          text_ary = text.split("\n")
          text_ary.each_with_index do |line, index|
            line_match = line.match(ABBRV_CAPTURE_REGEX)
            next if line_match.nil?
            new_line_match = new_line.match(ABBRV_CAPTURE_REGEX)
            ary = [new_line_match[1], line_match[1]]
            next if ary != ary.sort
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
