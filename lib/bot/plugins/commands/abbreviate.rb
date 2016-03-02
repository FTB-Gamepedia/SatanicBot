require 'cinch'
require 'array_utility'

module Plugins
  module Commands
    class Abbreviate
      include Cinch::Plugin
      using ArrayUtility

      match(/abbrv ([A-Z0-9\-]+) (.+)/i)

      DOC = 'Abbreivates a mod for the tilesheet extension. An op-only command. ' \
            '2 args: $abbrv <abbreviation> <mod_name>'.freeze
      Variables::NonConstants.add_command('abbrv', DOC)

      # Abbreviates the given mod with the given abbreviation. Fails when the
      #   mod or abbreviation are already on the list, or the user is not
      #   logged into LittleHelper. Will state the error code if there is any.
      # @param msg [Cinch::Message]
      # @param abbreviation [String] The abbreviation.
      # @param mod [String] The mod name.
      def execute(msg, abbreviation, mod)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        abbreviation = abbreviation.upcase
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          page = 'Module:Mods/list'
          butt = LittleHelper.init_wiki
          module_text = butt.get_text(page)
          if module_text =~ /[\s+]#{abbreviation} = \{\'/
            msg.reply('That abbreviation is already on the list.'.freeze)
          elsif module_text.include?("= {'#{mod}',")
            msg.reply('That mod is already on the list.'.freeze)
          else
            new_line = "    #{abbreviation} = {'#{mod}', [=[<translate>#{mod}</translate>]=]},"
            text_ary = module_text.split("\n")
            text_ary.each_with_index do |line, index|
              next unless line =~ /^[\s]+[\w]+ = \{'/
              ary = [new_line, line]
              next unless ary == ary.sort
              new_line.delete!(',', '') if text_ary.next(line) == '}'
              text_ary.insert(index, new_line)
              break
            end
            edit = butt.edit(page, text_ary.join("\n"), true, true, "Adding #{mod}")
            if edit.is_a?(Fixnum)
              msg.reply("Successfully abbreviated #{mod} as #{abbreviation}")
            else
              msg.reply("Failed! Error code: #{edit}")
            end
          end
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end
    end
  end
end
