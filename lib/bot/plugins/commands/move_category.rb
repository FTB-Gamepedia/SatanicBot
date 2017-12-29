require 'cinch'
require 'mediawiki/exceptions'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class MoveCategory < AuthorizedCommand
      include Cinch::Plugin
      include Plugins::Wiki
      ignore_ignored_users

      set(help: 'Moves one category to another, and edits all its members to reflect this change. 2 args: $movecat ' \
                '<old> -> <new>.',
          plugin_name: 'movecat')
      match(/movecat ([^\|\[\]<>%\+\?]+) \-> ([^\|\[\]<>%\+\?]+)/i)

      # Moves a category, and tries to update all of its members.
      # @param msg [Cinch::Message]
      # @param old_cat [String] The old category name.
      # @param new_cat [String] The new category name.
      def execute(msg, old_cat, new_cat)
        butt = wiki
        old_cat = old_cat =~ /^Category:/ ? old_cat : "Category:#{old_cat}"
        new_cat = new_cat =~ /^Category:/ ? new_cat : "Category:#{new_cat}"
        old_cat_contents = butt.get_text(old_cat)
        new_cat_contents = butt.get_text(new_cat)
        if !old_cat_contents.nil? && new_cat_contents.nil?
          summary = "Moving #{old_cat} to #{new_cat} through IRC."
          begin
            butt.create_page(new_cat, old_cat_contents, summary: summary)
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
            edit(t, msg, minor: true) do |text|
              return { terminate: nil } if text.nil?
              text.gsub!(old_cat, new_cat)
              text.gsub!(/\{\{[Cc]\|#{old_cat.delete('Category:')}\}\}/, "{{C|#{new_cat.delete('Category:')}}}")
              {
                text: text,
                success: nil,
                fail: nil,
                error: Proc.new { |e| "Something went wrong when editing #{t}! Error code: #{e.message} ... Continuing ..."}
              }
            end
          end

          msg.reply("Finished moving #{old_cat} to #{new_cat}")
        else
          msg.reply('Either the new category already exists, or the old one' \
                    ' does not. Please be sure to use valid categories.'.freeze)
        end
      end
    end
  end
end
