require 'cinch'

module Plugins
  module Commands
    class MajorCategory
      include Cinch::Plugin
      match(/newmodcat (.+)/i)

      def execute(msg, page)
        authedusers = Variables::NonConstants.get_authenticated_users
        page = "Category:#{page}" if /^Category:/ !~ page
        if authedusers.include?(msg.user.authname)
          butt = LittleHelper.init_wiki
          if butt.get_text(page).nil?
            text = "[[Category:Mod categories]]\n[[Category:Mods]]"
            edit = butt.create_page(page, text, 'New mod category.')
            if edit.is_a?(Fixnum)
              msg.reply("Succesfully created #{page}.")
            else
              msg.reply("Failure! Error code: #{edit}")
            end
          else
            msg.reply('That page already exists.')
          end
        else
          msg.reply('You must be authenticated for this action.')
        end
      end
    end

    class MinorCategory
      include Cinch::Plugin
      match(/newminorcat (.+)/i)

      def execute(msg, page)
        page = "Category:#{page}" if /^Category:/ !~ page
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          butt = LittleHelper.init_wiki
          if butt.get_text(page).nil?
            text = "[[Category:Mod categories]]\n[[Category:Minor Mods]]"
            edit = butt.create_page(page, text, 'New mod category.')
            if edit.is_a?(Fixnum)
              msg.reply("Succesfully created #{page}.")
            else
              msg.reply("Failure! Error code: #{edit}")
            end
          else
            msg.reply('That page already exists.')
          end
        else
          msg.reply('You must be authenticated for this action.')
        end
      end
    end
  end
end
