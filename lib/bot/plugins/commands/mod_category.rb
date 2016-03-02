require 'cinch'

module Plugins
  module Commands
    class NewCategory
      include Cinch::Plugin
      match(/newmodcat (.+)/i, method: :new_mod_category)
      match(/newminorcat (.+)/i, method: :new_minor_category)

      MOD_DOC = 'Creates a standard mod category. Op-only. 1 arg: $newmodcat <name>'.freeze
      MINOR_DOC = 'Creates a new minor mod category. Op-only. 1 arg: $newminorcat <name>'.freeze
      Variables::NonConstants.add_command('newmodcat', MOD_DOC)
      Variables::NonConstants.add_command('newminorcat', MINOR_DOC)

      def new_category(msg, page, minor = false)
        butt = LittleHelper.init_wiki
        if butt.get_text(page).nil?
          text = "[[Category:Mod categories]]\n"
          category = minor ? '[[Category:Minor Mods]]' : '[[Category:Mods]]'
          text << category
          edit = butt.create_page(page, text, 'New mod category.')
          if edit.is_a?(Fixnum)
            msg.reply("Succesfully created #{page}.")
          else
            msg.reply("Failure! Error code: #{edit}")
          end
        else
          msg.reply('That page already exists.'.freeze)
        end
      end

      # Creates a major (non-minor) mod category.
      # @param msg [Cinch::Message]
      # @param page [String] The mod name.
      def new_mod_category(msg, page)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        authedusers = Variables::NonConstants.get_authenticated_users
        page = "Category:#{page}" if /^Category:/ !~ page
        if authedusers.include?(msg.user.authname)
          new_category(msg, page)
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end

      # Creates a minor mod category.
      # @param msg [Cinch::Message]
      # @param page [String] The mod name.
      def new_minor_category(msg, page)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        page = "Category:#{page}" if /^Category:/ !~ page
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          new_category(msg, page, true)
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end
    end
  end
end
