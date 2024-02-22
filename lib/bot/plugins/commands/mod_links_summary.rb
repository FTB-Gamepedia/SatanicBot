require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class ModLinksSummary < BaseCommand
      include Plugins::Wiki

      def initialize
        super(:modlinkssummary, 'Gets a summary of potentially problematic links within a mod page.', 'modlinkssummary <page>')
        @attributes[:min_args] = 1
      end

      SPECIAL_CATEGORIES = [
        'Disambiguation pages',
        'Modpacks'
      ].freeze

      REDIRECT_REGEX = /\#REDIRECT \[\[(.+)\]\]/

      def create_paste(page_name, special_category_pages, other_mod_pages)
        other_mod_section = Pastee::Paste::Section.new(name: 'Pages not for this mod', contents: other_mod_pages.join("\n"))
        sections = [other_mod_section]
        special_category_pages.each do |category, pages|
          contents = pages.empty? ? 'none' : pages.join("\n")
          sections << Pastee::Paste::Section.new(name: category, contents: contents)
        end

        LittleHelper::PASTEE.submit(Pastee::Paste.new(description: "Summary of potentially bad links in #{page_name}", sections: sections))
      end

      def find_redirect_dest(title)
        text = wiki.get_text(title)
        return nil unless text
        match = text.match(REDIRECT_REGEX)
        match ? find_redirect_dest(match[1]) : title
      end

      def execute(event, args)
        page_name = args.join('_')
        links_in_page = wiki.get_all_links_in_page(page_name)
        unless links_in_page
          msg.reply('This page does not exist.')
          return
        end
        links_in_page.map! { |title| find_redirect_dest(title) }
        links_in_page.uniq!
        links_in_page.compact!
        mod_cat_for_page = wiki.get_categories_in_page(page_name).select do |category|
          wiki.get_categories_in_page(category).include?('Category:Mods')
        end[0]
        other_mod_pages = links_in_page.reject { |title| wiki.get_categories_in_page(title).include?(mod_cat_for_page) }
        special_category_pages = Hash.new([])
        SPECIAL_CATEGORIES.each do |special_category|
          all_pages_in_category = wiki.get_category_members(special_category)
          special_category_pages[special_category] = links_in_page.select { |title| all_pages_in_category.include?(title) }
          other_mod_pages.reject! { |title| special_category_pages[special_category].include?(title) }
        end

        return "http://paste.ee/p/#{create_paste(page_name, special_category_pages, other_mod_pages)}"
      end
    end
  end
end
