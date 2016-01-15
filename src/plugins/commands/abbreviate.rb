require 'cinch'

module Plugins
  module Commands
    class Abbreviate
      include Cinch::Plugin

      match(/abbrv ([A-Z0-9\-]+) (.+)/i)

      doc = 'Abbreivates a mod for the tilesheet extension. ' \
            'An op-only command. 2 args: $abbrv <abbreviation> <mod_name>'
      Variables::NonConstants.add_command('abbrv', doc)

      # Abbreviates the given mod with the given abbreviation. Fails when the
      #   mod or abbreviation are already on the list, or the user is not
      #   logged into LittleHelper. Will state the error code if there is any.
      # @param msg [Cinch::Message]
      # @param abbreviation [String] The abbreviation.
      # @param mod [String] The mod name.
      def execute(msg, abbreviation, mod)
        abbreviation = abbreviation.upcase
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          page = 'Module:Mods/list'
          butt = LittleHelper.init_wiki
          module_text = butt.get_text(page)
          if module_text =~ /[\s+]#{abbreviation} = \{\'/
            msg.reply('That abbreviation is already on the list.')
          elsif module_text.include?("= {'#{mod}',")
            msg.reply('That mod is already on the list.')
          else
            replace = "local modsByAbbrv = {\n    #{abbreviation} = {'#{mod}', " \
                      "[=[<translate>#{mod}</translate>]=]},"
            module_text = module_text.gsub(/local modsByAbbrv = \{/, replace)
            edit = butt.edit(page, module_text, true, true, "Adding #{mod}")
            if edit.is_a?(Fixnum)
              msg.reply("Successfully abbreviated #{mod} as #{abbreviation}")
            else
              msg.reply("Failed! Error code: #{edit}")
            end
          end
        else
          msg.reply('You must be logged in for this command.')
        end
      end
    end
  end
end
