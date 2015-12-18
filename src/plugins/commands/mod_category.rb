require 'cinch'

module Plugins
  module Commands
    class MajorCategory
      include Cinch::Plugin
      match(/newmodcat (.+)/i, method: :new_mod_category)
      match(/newminorcat (.+)/i, method: :new_minor_category)

      def new_category(msg, page, minor = false)
        butt = LittleHelper.init_wiki
        if butt.get_text(page).nil?
          text = "[[Category:Mod categories]]\n"
          text << minor ? '[[Category:Minor Mods]]' : '[[Category:Mods]]'
          edit = butt.create_page(page, text, 'New mod category.')
          if edit.is_a?(Fixnum)
            msg.reply("Succesfully created #{page}.")
          else
            msg.reply("Failure! Error code: #{edit}")
          end
        else
          msg.reply('That page already exists.')
        end
      end

      # Creates a major (non-minor) mod category.
      # @param msg [Cinch::Message]
      # @param page [String] The mod name.
      def new_mod_category(msg, page)
        authedusers = Variables::NonConstants.get_authenticated_users
        page = "Category:#{page}" if /^Category:/ !~ page
        if authedusers.include?(msg.user.authname)
          new_category(msg, page)
        else
          msg.reply('You must be authenticated for this action.')
        end
      end

      # Creates a minor mod category.
      # @param msg [Cinch::Message]
      # @param page [String] The mod name.
      def new_minor_category(msg, page)
        page = "Category:#{page}" if /^Category:/ !~ page
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          new_category(msg, page, true)
        else
          msg.reply('You must be authenticated for this action.')
        end
      end
    end
  end
end
