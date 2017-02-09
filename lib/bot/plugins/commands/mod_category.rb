require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class NewCategory < AuthorizedCommand
      include Cinch::Plugin
      ignore_ignored_users
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
          begin
          edit = butt.create_page(page, text, 'New mod category.')
          if edit
            msg.reply("Successfully created #{page}.")
          else
            msg.reply('Failed! There was no change to the page')
          end
          rescue EditError => e
            msg.reply("Failed! Error code: #{e.message}")
          end
        else
          msg.reply('That page already exists.'.freeze)
        end
      end

      # Creates a major (non-minor) mod category.
      # @param msg [Cinch::Message]
      # @param page [String] The mod name.
      def new_mod_category(msg, page)
        page = "Category:#{page}" if /^Category:/ !~ page
        new_category(msg, page)
      end

      # Creates a minor mod category.
      # @param msg [Cinch::Message]
      # @param page [String] The mod name.
      def new_minor_category(msg, page)
        page = "Category:#{page}" if /^Category:/ !~ page
        new_category(msg, page, true)
      end
    end
  end
end
