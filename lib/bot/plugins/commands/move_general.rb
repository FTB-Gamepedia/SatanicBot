require 'cinch'
require 'string-utility'
require_relative 'base_command'

module Plugins
  module Commands
    class MoveGeneral < BaseCommand
      include Cinch::Plugin
      using StringUtility
      ignore_ignored_users

      match(/safemove (.+) -> (.+)/i)

      DOC = "Moves a page to a new page, with no redirect, including subpages. Edits all of the page's " \
            'backlinks. 2 args: $safemove <old> -> <new> Args must be separated by ->'.freeze
      Variables::NonConstants.add_command('safemove', DOC)

      # Safely moves a page by updating all of the backlinks possible.
      # @param msg [Cinch::Message]
      # @param old_page [String] The old page name.
      # @param new_page [String] The new page name.
      def execute(msg, old_page, new_page)
        authed_users = Variables::NonConstants.get_authenticated_users
        if authed_users.include? msg.user.authname
          butt = LittleHelper.init_wiki
          begin
            move = butt.move(old_page, new_page, 'Moving page from IRC.')
          rescue EditError => e
            msg.reply("Failed! Error code: #{e.message}")
          end

          if move
            links = butt.what_links_here(old_page)
            links.each do |l|
              text = butt.get_text(l)
              next if text.nil? || text !~ /#{old_page}/
              text.safely_gsub!(/\[\[#{old_page}\|/, "[[#{new_page}|")
              text.safely_gsub!(/\[\[#{old_page}\]\]/, "[[#{new_page}]]")
              text.safely_gsub!(/\{[Ll]\|#{old_page}\|/, "{{L|#{new_page}|")
              text.safely_gsub!(/\{\{[Ll]\|#{old_page}\}\}/, "{{L|#{new_page}}}")
              begin
                butt.edit(l, text, true)
              rescue EditError => e
                msg.reply("Something went wrong when editing #{l}! Error code: #{e.message} ... Continuing ...")
              end
            end
            msg.reply('Finished.'.freeze)
          end
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end
    end
  end
end
