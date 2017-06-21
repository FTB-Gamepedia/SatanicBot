require 'cinch'
require 'string-utility'
require_relative 'base_command'

module Plugins
  module Commands
    class MoveGeneral < AuthorizedCommand
      include Cinch::Plugin
      using StringUtility
      ignore_ignored_users

      set(help: 'Moves a page to a new page, with no redirect, including subpages. Edits all backlinks to reflect ' \
                'this change. Op-only. 2 args: $safemove <old> -> <new>',
          plugin_name: 'safemove')
      match(/safemove (.+) -> (.+)/i)

      # Safely moves a page by updating all of the backlinks possible.
      # @param msg [Cinch::Message]
      # @param old_page [String] The old page name.
      # @param new_page [String] The new page name.
      def execute(msg, old_page, new_page)
        butt = LittleHelper.init_wiki
        begin
          move = butt.move(old_page, new_page, reason: 'Moving page from IRC.', suppress_redirect: true)
        rescue EditError => e
          msg.reply("Failed! Error code: #{e.message}")
        end

        if move
          links = butt.what_links_here(old_page)
          links.each do |l|
            text = butt.get_text(l)
            next if text.nil? || text !~ /#{old_page}/
            text.gsub!(/\[\[#{old_page}\|/, "[[#{new_page}|")
            text.gsub!(/\[\[#{old_page}\]\]/, "[[#{new_page}]]")
            text.gsub!(/\{[Ll]\|#{old_page}\|/, "{{L|#{new_page}|")
            text.gsub!(/\{\{[Ll]\|#{old_page}\}\}/, "{{L|#{new_page}}}")
            begin
              butt.edit(l, text, minor: true)
            rescue EditError => e
              msg.reply("Something went wrong when editing #{l}! Error code: #{e.message} ... Continuing ...")
            end
          end
          msg.reply('Finished.'.freeze)
        end
      end
    end
  end
end
