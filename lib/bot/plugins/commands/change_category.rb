require 'cinch'

module Plugins
  module Commands
    class ChangeCategory
      include Cinch::Plugin

      match(/changecat (.+) \| (.+) -> (.+)/)

      DOC = 'Changes a category in a page to a different one. 3 args: $changecat <page> | <old> -> <new> ' \
            'All separation characters are required.'.freeze
      Variables::NonConstants.add_command('changecat', DOC)

      # Changes any category on any page.
      # @param msg [Cinch::Message]
      # @param page [String] The page to edit.
      # @param old_cat [String] The old category needed to be changed.
      # @param new_cat [String] What to change the category to.
      def execute(msg, page, old_cat, new_cat)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        authedusers = Variables::NonConstants.get_authenticated_users
        old_cat = "Category:#{old_cat}" if /^Category:/ !~ old_cat
        new_cat = "Category:#{new_cat}" if /^Category:/ !~ new_cat
        if authedusers.include?(msg.user.authname)
          butt = LittleHelper.init_wiki
          page_text = butt.get_text(page)
          if page_text.nil?
            msg.reply('That page does not exist.'.freeze)
            return
          end
          if butt.get_text(new_cat).nil?
            msg.reply('That category does not exist.'.freeze)
            return
          end
          page_text.gsub!(old_cat, new_cat)
          begin
            edit = butt.edit(page, page_text, true)
            if edit
              msg.reply('Finished.'.freeze)
            else
              msg.reply('Failed! There was no change to the page.')
            end
          rescue EditError => e
            msg.reply("Failed! Error code: #{e.message}")
          end
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end
    end
  end
end
