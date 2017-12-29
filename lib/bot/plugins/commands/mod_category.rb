require 'cinch'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class NewCategory < AuthorizedCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Creates a new mod category. Op-only. 1 arg: $newmodcat <name>', plugin_name: 'newmodcat')
      match(/newmodcat (.+)/i)

      def execute(msg, page)
        page = "Category:#{page}" if /^Category:/ !~ page

        butt = wiki
        if butt.get_text(page).nil?
          text = '[[Category:Mods]]'
          begin
            edit = butt.create_page(page, text, summary: 'New mod category.')
            if edit
              msg.reply("Successfully created #{page}.")
            else
              msg.reply('Failed! There was no change to the page')
            end
          rescue EditError => e
            msg.reply("Failed! Error code: #{e.message}")
          end
        else
          msg.reply('That page already exists.'.freeze)
        end
      end
    end
  end
end
