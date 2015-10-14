require 'cinch'

module Plugins
  module Commands
    class Abbreviate
      include Cinch::Plugin

      match(/abbrv ([A-Z0-9]+) (.+)/i)

      def execute(msg, abbreviation, mod)
        abbreviation = abbreviation.upcase
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          page = 'Module:Mods/list'
          butt = LittleHelper.init_wiki
          module_text = butt.get_text(page)
          if /#{abbreviation}/ =~ module_text
            msg.reply('That abbreviation is already on the list.')
          elsif /#{mod}/ =~ module_text
            msg.reply('That mod is already on the list.')
          else
            replace = "local modsByAbbrv = {\n    #{abbreviation} = {'#{mod}', " \
                      "[=[<translate>#{mod}</translate>]=]},"
            module_text = module_text.gsub(/local modsByAbbrv = \{/, replace)
            edit = butt.edit(page, module_text, "Adding #{mod}", true)
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
