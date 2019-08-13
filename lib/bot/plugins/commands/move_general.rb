require 'cinch'
require 'string-utility'
require 'mediawiki/exceptions'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class MoveGeneral < AuthorizedCommand
      include Cinch::Plugin
      include Plugins::Wiki
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
        begin
          move = wiki.move(old_page, new_page, reason: 'Moving page from IRC.', suppress_redirect: true)
        rescue MediaWiki::Butt::EditError => e
          msg.reply("Failed! Error code: #{e.message}")
        end

        if move
          links = wiki.what_links_here(old_page)
          links.each do |l|
            edit(l, msg, minor: true) do |text|
              return { terminate: nil } if text.nil? || text !~ /#{old_page}/
              text.gsub!(/\[\[#{old_page}\|/, "[[#{new_page}|")
              text.gsub!(/\[\[#{old_page}\]\]/, "[[#{new_page}]]")
              text.gsub!(/\{[Ll]\|#{old_page}\|/, "{{L|#{new_page}|")
              text.gsub!(/\{\{[Ll]\|#{old_page}\}\}/, "{{L|#{new_page}}}")
              {
                text: text,
                success: nil,
                fail: nil,
                error: Proc.new { |e| "Something went wrong when editing #{l}! Error code: #{e.message} ... Continuing ..." }
              }
            end
          end
          msg.reply('Finished.'.freeze)
        end
      end
    end
  end
end
