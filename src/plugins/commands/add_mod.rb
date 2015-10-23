require 'cinch'

module Plugins
  module Commands
    class AddMod
      include Cinch::Plugin

      match(/addmod (.+)/i, method: :execute_major)
      match(/addminor (.+)/i, method: :execute_minor)

      def execute(msg, mod, minor = false)
        butt = LittleHelper.init_wiki
        page =
          if minor
            'Template:Minor Mods'
          else
            'Template:Mods'
          end
        category =
          if minor
            'Category:Minor Mods'
          else
            'Category:Mods'
          end

        if butt.get_text(mod).nil?
          msg.reply('Sorry, that mod is not a valid page.')
        else
          if butt.get_categories_in_page(mod).include?(category)
            text = butt.get_text(page)
            text = text.gsub('<noinclude>', '')
            text = text.gsub('<translate>', '')
            text = text.gsub('<!--T:1-->', '')
            text = text.gsub('</noinclude>', '')
            text = text.gsub('</translate>', '')
            text = text.gsub(/^$\n/, '')
            puts text
            text = text.gsub(/\{\{L\|\w+\}\}\n/, "{{L|\\1}} {{*}}\n")
            text = "#{text}\n{{L|#{mod}}} {{*}}"
            lines = text.split(/\n/)
            lines = lines.sort
            text = lines.join("\n")
            text = text.gsub("{{*}}\n<", "\n<")
            text = "<noinclude><translate><!--T:1-->\n</noinclude>#{text}\n" \
                   "<noinclude></translate></noinclude>"

            edit = butt.edit(page, text, true, true, "Add #{mod}")
            if edit.is_a?(Fixnum)
              msg.reply("Successfully added #{mod} to #{page}")
            else
              msg.reply("Failed! Error code: #{edit}")
            end
          else
            msg.reply('Sorry, that page is not in its assumed category.')
          end
        end
      end

      def execute_major(msg, mod)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          execute(msg, mod)
        else
          msg.reply('You must be authenticated for this action.')
        end
      end

      def execute_minor(msg, mod)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          execute(msg, mod, true)
        else
          msg.reply('You must be authenticated for this action.')
        end
      end
    end
  end
end
