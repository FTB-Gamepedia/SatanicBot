require 'cinch'

module Plugins
  module Commands
    class NewVanilla
      include Cinch::Plugin
      match(/newvanilla (.+) \| (.+)/i)

      doc = 'Creates a new page for a Vanilla thing. Op-only. 1 arg: ' \
            '$newvanilla <page> | <type>'
      Variables::NonConstants.add_command('newvanilla', doc)

      def execute(msg, page, type)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          butt = LittleHelper.init_wiki
          if butt.get_text(page).nil?
            text = "{{Vanilla|type=#{type}}}"
            edit = butt.create_page(page, text, 'New vanilla page.')
            if edit.is_a?(Fixnum)
              msg.reply("Succesfully created #{page}.")
            else
              msg.reply("Failure! Error code: #{edit}")
            end
          else
            msg.reply('That page already exists.')
          end
        else
          msg.reply('You must be authenticated for this action.')
        end
      end
    end
  end
end
