require 'cinch'

module Plugins
  module Commands
    class AddNavbox
      include Cinch::Plugin

      match(/addnav ([^\|\[\]\<\>\%\+\?]+) \| ([^\|\[\]\<\>\%\+\?]+)/i)

      # Adds a navigation template to the list of navigation templates.
      # @param msg [Cinch::Message]
      # @param navbox [String] The navbox's name.
      # @param content [String] What the navbox contains. This is usually just
      #   a mod name.
      def execute(msg, navbox, content)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          navbox = navbox.chomp
          content = content.chomp
          navbox = navbox.sub(/[Nn]avbox/, '')
          page = 'Template:Navbox List'
          butt = LittleHelper.init_wiki
          text = butt.get_text(page)
          if butt.get_text("Template:Navbox #{navbox}").nil?
            msg.reply('That Navbox does not exist.')
          elsif butt.get_text(content).nil?
            msg.reply('That content page does not exist.')
          else
            if /\{\{[Tt]l\|Navbox #{navbox}\}\}/ =~ text
              msg.reply('That navbox is already on the list.')
            elsif /\{\{[Ll]\|#{content}\}\}/ =~ text
              msg.reply('That content is already on the list.')
            else
              addition = "|-\n| {{Tl|Navbox #{navbox}}} ||" \
                        " {{L|#{content}}} ||\n|}"
              text = text.gsub(/\|\}/, addition)
              summary = "Add the #{content} navbox (Navbox #{navbox})"
              edit = butt.edit(page, text, true, true, summary)
              if edit.is_a?(Fixnum)
                msg.reply("Successfully appended #{navbox} to the list!")
              else
                msg.reply("Failed! Error code: #{edit}")
              end
            end
          end
        else
          msg.reply('You must be authenticated for this action.')
        end
      end
    end
  end
end
