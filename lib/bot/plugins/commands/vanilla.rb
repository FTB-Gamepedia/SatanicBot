require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class NewVanilla < AuthorizedCommand
      include Cinch::Plugin
      ignore_ignored_users
      match(/newvanilla (.+) \| (.+)/i)

      DOC = 'Creates a new page for a Vanilla thing. Op-only. 1 arg: $newvanilla <page> | <type>'.freeze
      Variables::NonConstants.add_command('newvanilla', DOC)

      def execute(msg, page, type)
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
      end
    end
  end
end
