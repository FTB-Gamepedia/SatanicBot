require 'cinch'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class NewVanilla < AuthorizedCommand
      include Cinch::Plugin
      include Plugins::Wiki
      ignore_ignored_users

      set(help: 'Creates a new page for a Vanilla thing. Op-only. 2 args: $newvanilla <page> | <type>',
          plugin_name: 'newvanilla')
      match(/newvanilla (.+) \| (.+)/i)

      def execute(msg, page, type)
        butt = wiki
        if butt.get_text(page).nil?
          text = "{{Vanilla|type=#{type}}}"
          begin
            butt.create_page(page, text, summary: 'New vanilla page.'.freeze)
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
