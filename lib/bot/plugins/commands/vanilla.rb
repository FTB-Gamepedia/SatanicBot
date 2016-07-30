require 'cinch'

module Plugins
  module Commands
    class NewVanilla
      include Cinch::Plugin
      match(/newvanilla (.+) \| (.+)/i)

      DOC = 'Creates a new page for a Vanilla thing. Op-only. 1 arg: $newvanilla <page> | <type>'.freeze
      Variables::NonConstants.add_command('newvanilla', DOC)

      def execute(msg, page, type)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          butt = LittleHelper.init_wiki
          if butt.get_text(page).nil?
            text = "{{Vanilla|type=#{type}}}"
            begin
              butt.create_page(page, text, 'New vanilla page.'.freeze)
            rescue EditError => e
              msg.reply("Failed! Error code: #{e.message}")
            end

            msg.reply("Succesfully created #{page}.")
          else
            msg.reply('That page already exists.'.freeze)
          end
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end
    end
  end
end
