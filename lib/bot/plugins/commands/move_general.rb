require 'cinch'
require 'string-utility'

module Plugins
  module Commands
    class MoveGeneral
      include Cinch::Plugin
      using StringUtility

      match(/safemove (.+) -> (.+)/i)

      doc = 'Moves a page to a new page, with no redirect, including ' \
            "subpages. Edits all of the page's backlinks. 2 args: " \
            '$safemove <old> -> <new> Args must be separated by ->'
      Variables::NonConstants.add_command('safemove', doc)

      # Safely moves a page by updating all of the backlinks possible.
      # @param msg [Cinch::Message]
      # @param old_page [String] The old page name.
      # @param new_page [String] The new page name.
      def execute(msg, old_page, new_page)
        if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          return
        end
        authed_users = Variables::NonConstants.get_authenticated_users
        if authed_users.include? msg.user.authname
          butt = LittleHelper.init_wiki
          move = butt.move(old_page, new_page, 'Moving page from IRC.')
          if move
            links = butt.what_links_here(old_page, 5000)
            links.each do |l|
              text = butt.get_text(l)
              next if text.nil? || text !~ /#{old_page}/
              text.safely_gsub!(/\[\[#{old_page}\|/, "[[#{new_page}|")
              text.safely_gsub!(/\[\[#{old_page}\]\]/, "[[#{new_page}]]")
              text.safely_gsub!(/\{[Ll]\|#{old_page}\|/, "{{L|#{new_page}|")
              text.safely_gsub!(/\{\{[Ll]\|#{old_page}\}\}/, "{{L|#{new_page}}}")
              edit = butt.edit(l, text, true)
              msg.reply("Something went wrong when editing #{l}! " \
                        "Error code: #{edit} ... Continuing...") unless edit.is_a?(Fixnum)
            end
            msg.reply('Finished.'.freeze)
          else
            msg.reply("Failed! Error code: #{move}")
          end
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end
    end
  end
end
