require 'cinch'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class CategoryMembers < AuthorizedCommand
      include Cinch::Plugin
      include Plugins::Wiki
      ignore_ignored_users

      set(help: 'Gets a comprehensive summary of all category members, organized by the other categories of each ' \
                'member. Use this command with caution, as it will take a very long time to process. Uploads the ' \
                'summary to Pastee. Op-only. 1 arg: $categorymembers <top category>', plugin_name: 'categorymembers')
      match(/categorymembers (.+)/i)

      # Creates a massive comprehensive summary of the category members of any
      #   given category on the wiki, and puts it on Pastee. The comprehensive
      #   summary includes a list of all category members, and those members
      #   organized by their other categories.
      # @param msg [Cinch::Message]
      # @param category [String] The top category.
      def execute(msg, category)
        category = "Category:#{category}" if /^Category:/ !~ category
        butt = wiki
        members = butt.get_category_members(category)
        paste_hash = {}
        members.each do |page|
          next unless page
          categories = butt.get_categories_in_page(page)
          categories.each do |cat|
            paste_hash[cat] = [] unless paste_hash.key?(cat)
            paste_hash[cat] << page
          end
        end
        paste_contents = "Comprehensive summary of #{category} members\n\n"
        paste_hash.each do |cat, pages|
          page_string = pages.join("\n* ")
          paste_contents << "## #{cat}\n* #{page_string}\n\n"
        end
        id = LittleHelper::PASTEE.submit(paste_contents, "Summary of #{category} members.")
        msg.reply("http://paste.ee/p/#{id}")
      end
    end
  end
end
