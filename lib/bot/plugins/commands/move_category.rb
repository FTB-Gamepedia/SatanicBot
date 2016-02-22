require 'cinch'

module Plugins
  module Commands
    class MoveCategory
      include Cinch::Plugin

      match(/movecat ([^\|\[\]<>%\+\?]+) \-> ([^\|\[\]<>%\+\?]+)/i)

      doc = 'Moves one category to another, and edits all its members. ' \
            '2 args: $movecat <old> -> <new> Args must be separated ' \
            'with a ->.'
      Variables::NonConstants.add_command('movecat', doc)

      # Moves a category, and tries to update all of its members.
      # @param msg [Cinch::Message]
      # @param old_cat [String] The old category name.
      # @param new_cat [String] The new category name.
      def execute(msg, old_cat, new_cat)
        if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          return
        end
        authed_users = Variables::NonConstants.get_authenticated_users
        if authed_users.include? msg.user.authname
          butt = LittleHelper.init_wiki
          old_cat = old_cat =~ /^Category:/ ? old_cat : "Category:#{old_cat}"
          new_cat = new_cat =~ /^Category:/ ? new_cat : "Category:#{new_cat}"
          old_cat_contents = butt.get_text(old_cat)
          new_cat_contents = butt.get_text(new_cat)
          if !old_cat_contents.nil? && new_cat_contents.nil?
            summary = "Moving #{old_cat} to #{new_cat} through IRC."
            create = butt.create_page(new_cat, old_cat_contents, summary)
            unless create.is_a?(Fixnum)
              msg.reply('Something went wrong when creating the page ' \
                        "#{new_cat}! Error code: #{create}")
              return
            end

            delete = butt.delete(old_cat, summary)
            unless delete
              msg.reply("Something went wrong when deleting #{old_cat}!" \
                        "Error code: #{delete}")
              return
            end

            members = butt.get_category_members(old_cat, 5000)
            members.each do |t|
              text = butt.get_text(t)
              next if text.nil?
              text.gsub!(old_cat, new_cat)
              text.gsub!(/\{\{[Cc]|#{old_cat}\}\}/, "{{C|#{new_cat}}}")
              edit = butt.edit(t, text, true)
              msg.reply("Something went wrong when editing #{t}! " \
                        "Error code: #{edit} ... Continuing...") unless edit.is_a?(Fixnum)
            end

            msg.reply("Finished moving #{old_cat} to #{new_cat}")
          else
            msg.reply('Either the new category already exists, or the old one' \
                      ' does not. Please be sure to use valid categories.'.freeze)
          end
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end
    end
  end
end
