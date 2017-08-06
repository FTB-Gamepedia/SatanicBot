require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class ModLinksSummary < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Gets a summary of problematic links within a mod page. 1 arg: $modlinkssummary <page name>')
      match(/modlinkssummary (.+)/)

      def create_paste(page_name, disambiguation_pages, other_mod_pages)
        str = "== Disambiguation pages ==\n"
        str << disambiguation_pages.join("\n")
        str << "\n\n"
        str << "== Pages not for this mod ==\n"
        str << other_mod_pages.join("\n")
        str << "\n\n"

        LittleHelper::PASTEE.submit(str, "Summary of bad links in #{page_name}")
      end

      def execute(msg, page_name)
        mw = LittleHelper.init_wiki
        links_in_page = mw.get_all_links_in_page(page_name)
        unless links_in_page
          msg.reply('This page does not exist.')
          return
        end
        category = mw.get_categories_in_page(page_name).select do |category|
          mw.get_categories_in_page(category).include?('Category:Mods')
        end[0]
        all_disambiguation_pages = mw.get_category_members('Disambiguation pages')
        disambiguation_pages_in_page = []
        other_mod_pages_in_page = []
        links_in_page.each do |title|
          next unless mw.get_text(title)
          disambiguation_pages_in_page << title if all_disambiguation_pages.include?(title)
          if category
            other_mod_pages_in_page << title unless mw.get_categories_in_page(title).include?(category)
          end
        end

        msg.reply("http://paste.ee/p/#{create_paste(page_name, disambiguation_pages_in_page, other_mod_pages_in_page)}")
      end
    end
  end
end
class ModLinksSummary
end
