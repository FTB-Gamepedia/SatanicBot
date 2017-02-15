require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class IsDisambiguation < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Returns whether the provided page is a disambiguation page. 1 arg: $dis? <page>', plugin_name: 'dis?')
      match(/dis\? (.+)/i)

      def execute(msg, page_name)
        wiki = LittleHelper.init_wiki
        text = wiki.get_text(page_name)
        if text
          is_dis = wiki.get_categories_in_page(page_name).include?('Category:Disambiguation pages')
          msg.reply("#{page_name} is #{is_dis ? 'a' : 'not a'} disambiguation page.")
        else
          msg.reply("#{page_name} is not a page.")
        end
      end
    end
  end
end
