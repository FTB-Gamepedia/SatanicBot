require 'cinch'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class ChangeCategory < AuthorizedCommand
      include Cinch::Plugin
      include Plugins::Wiki
      ignore_ignored_users

      set(help: 'Changes a category in a page to a different one. Op-only. 3 args: $changecat <page> | <old> -> <new>',
          plugin_name: 'changecat')
      match(/changecat (.+) \| (.+) -> (.+)/)

      # Changes any category on any page.
      # @param msg [Cinch::Message]
      # @param page [String] The page to edit.
      # @param old_cat [String] The old category needed to be changed.
      # @param new_cat [String] What to change the category to.
      def execute(msg, page, old_cat, new_cat)
        old_cat = "Category:#{old_cat}" if /^Category:/ !~ old_cat
        new_cat = "Category:#{new_cat}" if /^Category:/ !~ new_cat
        edit(page, msg, minor: true) do |text|
          if text.nil?
            next { terminate: Proc.new { 'That page does not exist.' } }
          end
          if wiki.get_text(new_cat).nil?
            next { terminate: Proc.new { 'That category does not exist.' } }
          end
          text.gsub!(old_cat, new_cat)
          {
            text: text,
            success: Proc.new { 'Finished.' },
            fail: Proc.new { 'Failed! There was no change to the page.' },
            error: Proc.new { |e| "Failed! Error code: #{e.message}" }
          }
        end
      end
    end
  end
end
