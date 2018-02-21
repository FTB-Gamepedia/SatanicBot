require 'cinch'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class ModLinksSummary < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Gets a summary of problematic links within a mod page. 1 arg: $modlinkssummary <page name>')
      match(/modlinkssummary (.+)/)

      SPECIAL_CATEGORIES = [
        'Disambiguation pages',
        'Modpacks'
      ].freeze

      REDIRECT_REGEX = /\#REDIRECT \[\[(.+)\]\]/

      def create_paste(page_name, special_category_pages, other_mod_pages)
        str = "== Pages not for this mod ==\n"
        str << other_mod_pages.join("\n")
        str << "\n\n"
        special_category_pages.each do |category, pages|
          str << "== #{category} ==\n"
          str << pages.join("\n")
          str << "\n\n"
        end

        LittleHelper::PASTEE.submit(str, "Summary of bad links in #{page_name}")
      end

      def find_redirect_dest(mw, title)
        text = mw.get_text(title)
        return nil unless text
        match = text.match(REDIRECT_REGEX)
        match ? find_redirect_dest(mw, match[1]) : title
      end

      def execute(msg, page_name)
        mw = wiki
        links_in_page = mw.get_all_links_in_page(page_name)
        unless links_in_page
          msg.reply('This page does not exist.')
          return
        end
        links_in_page.map! { |title| find_redirect_dest(mw, title) }
        links_in_page.uniq!
        links_in_page.compact!
        mod_cat_for_page = mw.get_categories_in_page(page_name).select do |category|
          mw.get_categories_in_page(category).include?('Category:Mods')
        end[0]
        other_mod_pages = links_in_page.reject { |title| mw.get_categories_in_page(title).include?(mod_cat_for_page) }
        special_category_pages = Hash.new([])
        SPECIAL_CATEGORIES.each do |special_category|
          all_pages_in_category = mw.get_category_members(special_category)
          special_category_pages[special_category] = links_in_page.select { |title| all_pages_in_category.include?(title) }
          other_mod_pages.reject! { |title| special_category_pages[special_category].include?(title) }
        end

        msg.reply("http://paste.ee/p/#{create_paste(page_name, special_category_pages, other_mod_pages)}")
      end
    end
  end
end
