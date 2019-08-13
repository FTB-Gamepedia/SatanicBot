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
        old_cat = old_cat =~ /^Category:/ ? old_cat : "Category:#{old_cat}"
        new_cat = new_cat =~ /^Category:/ ? new_cat : "Category:#{new_cat}"

        summary = "Moving #{old_cat} to #{new_cat} through IRC."

        old_cat_c_regex = /\{\{[Cc]\|#{old_cat.delete_prefix('Category:')}\}\}/
        new_cat_c = "{{C|#{new_cat.delete_prefix('Category:')}}}"

        begin
          wiki.move(old_cat, new_cat, reason: summary, suppress_redirect: true)
        rescue MediaWiki::Butt::EditError => e
          msg.reply("Something went wrong when moving the category #{old_cat} to #{new_cat}! Error code: #{e.message}")
        end

        members = wiki.get_category_members(old_cat, 'page|file|subcat')
        members.each do |t|
          edit(t, msg, minor: true, summary: summary) do |text|
            return { terminate: nil } if text.nil?
            text.gsub!(old_cat, new_cat)
            text.gsub!(old_cat_c_regex, new_cat_c)
            {
              text: text,
              success: nil,
              fail: nil,
              error: Proc.new { |e| "Something went wrong when editing #{t}! Error code: #{e.message} ... Continuing ..."}
            }
          end
        end

        msg.reply("Finished moving #{old_cat} to #{new_cat}")
      end
    end
  end
end
