require 'cinch'
require 'mediawiki/exceptions'
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
        if wiki.get_text(page).nil?
          text = "{{Vanilla|type=#{type}}}"
          begin
            wiki.create_page(page, text, summary: 'New vanilla page.'.freeze)
          rescue MediaWiki::Butt::EditError => e
            msg.reply("Failed! Error code: #{e.message}")
          end

          msg.reply("Successfully created #{page}.")
        else
          msg.reply('That page already exists.'.freeze)
        end
      end
    end
  end
end
