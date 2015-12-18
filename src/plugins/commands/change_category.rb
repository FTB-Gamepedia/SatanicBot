require 'cinch'

module Plugins
  module Commands
    class ChangeCategory
      include Cinch::Plugin

      match(/changecat (.+) \| (.+) -> (.+)/)

      # Changes any category on any page.
      # @param msg [Cinch::Message]
      # @param page [String] The page to edit.
      # @param old_cat [String] The old category needed to be changed.
      # @param new_cat [String] What to change the category to.
      def execute(msg, page, old_cat, new_cat)
        authedusers = Variables::NonConstants.get_authenticated_users
        old_cat = "Category:#{old_cat}" if /^Category:/ !~ old_cat
        new_cat = "Category:#{new_cat}" if /^Category:/ !~ new_cat
        if authedusers.include?(msg.user.authname)
          butt = LittleHelper.init_wiki
          page_text = butt.get_text(page)
          if page_text.nil?
            msg.reply('That page does not exist.')
            return
          end
          page_text.gsub!(old_cat, new_cat)
          edit = butt.edit(page, page_text, true)
          if !edit.is_a?(Fixnum)
            msg.reply("Something went wrong! Error code: #{edit}")
          else
            msg.reply('Finished.')
          end
        else
          msg.reply('You must be authenticated for that command.')
        end
      end
    end
  end
end
