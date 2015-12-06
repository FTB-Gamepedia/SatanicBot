require 'cinch'

module Plugins
  module Commands
    class MoveGeneral
      include Cinch::Plugin

      match(/safemove (.+) -> (.+)/i)

      def execute(msg, old_page, new_page)
        authed_users = Variables::NonConstants.get_authenticated_users
        if authed_users.include? msg.user.authname
          butt = LittleHelper.init_wiki
          move = butt.move(old_page, new_page, 'Moving page from IRC.')
          if move == true
            links = butt.what_links_here(old_page, 5000)
            links.each do |l|
              text = butt.get_text(l)
              next if text.nil?
              text.gsub!(/\[\[#{old_page}\|/, "[[#{new_page}|")
              text.gsub!(/\[\[#{old_page}\]\]/, "#{new_page}]]")
              text.gsub!(/\{\{L\|#{old_page}\|/, "{{L|#{new_page}|")
              text.gsub!(/\{\{L\|#{old_page}\}\}/, "{{L|#{new_page}}}")
              edit = butt.edit(l, text, true)
              msg.reply("Something went wrong when editing #{l}! " \
                        "Error code: #{edit} ... Continuing...") unless edit.is_a?(Fixnum)
            end
            msg.reply('Finished.')
          else
            msg.reply("Failed! Error code: #{move}")
          end
        else
          msg.reply('You must be authenticated for this command.')
        end
      end
    end
  end
end
