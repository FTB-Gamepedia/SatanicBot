require 'cinch'
require 'mediawiki/exceptions'

module Plugins
  module Commands
    class MoveCategory
      include Cinch::Plugin

      match(/movecat ([^\|\[\]<>%\+\?]+) \-> ([^\|\[\]<>%\+\?]+)/i)

      DOC = 'Moves one category to another, and edits all its members. ' \
            '2 args: $movecat <old> -> <new> Args must be separated with a ->.'.freeze
      Variables::NonConstants.add_command('movecat', DOC)

      # Moves a category, and tries to update all of its members.
      # @param msg [Cinch::Message]
      # @param old_cat [String] The old category name.
      # @param new_cat [String] The new category name.
      def execute(msg, old_cat, new_cat)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        authed_users = Variables::NonConstants.get_authenticated_users
        if authed_users.include? msg.user.authname
          butt = LittleHelper.init_wiki
          old_cat = old_cat =~ /^Category:/ ? old_cat : "Category:#{old_cat}"
          new_cat = new_cat =~ /^Category:/ ? new_cat : "Category:#{new_cat}"
          old_cat_contents = butt.get_text(old_cat)
          new_cat_contents = butt.get_text(new_cat)
          if !old_cat_contents.nil? && new_cat_contents.nil?
            summary = "Moving #{old_cat} to #{new_cat} through IRC."
            begin
              butt.create_page(new_cat, old_cat_contents, summary)
            rescue EditError => e
              msg.reply("Something went wrong when creating the page #{new_cat}! Error code: #{e.message}")
            end

            begin
              butt.delete(old_cat, summary)
            rescue EditError => e
              msg.reply("Something went wrong when deleting #{old_cat}! Error code: #{e.message}")
            end


            members = butt.get_category_members(old_cat)
            members.each do |t|
              text = butt.get_text(t)
              next if text.nil?
              text.gsub!(old_cat, new_cat)
              text.gsub!(/\{\{[Cc]|#{old_cat}\}\}/, "{{C|#{new_cat}}}")
              begin
                butt.edit(t, text, true)
              rescue EditError => e
                msg.reply("Something went wrongwhen editing #{t}! Error code: #{e.message} ... Continuing ...")
              end

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
