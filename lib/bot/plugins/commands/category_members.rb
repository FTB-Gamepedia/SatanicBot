require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class CategoryMembers < AuthorizedCommand
      include Plugins::Wiki

      def initialize
        super(
          :categorymembers, 
          'Gets a comprehensive summary of all category members, organized by the other categories of each ' \
          'member. Use this command with caution, as it will take a very long time to process. Uploads the ' \
          'summary to Pastee.',
          'categorymembers <top category>')
        @attributes[:min_args] = 1
      end

      # Creates a massive comprehensive summary of the category members of any
      #   given category on the wiki, and puts it on Pastee. The comprehensive
      #   summary includes a list of all category members, and those members
      #   organized by their other categories.
      def execute(event, args)
        category = args.join(' ')
        category = "Category:#{category}" if /^Category:/ !~ category
        members = wiki.get_category_members(category)
        paste_hash = {}
        members.each do |page|
          next unless page
          categories = wiki.get_categories_in_page(page)
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
        id = LittleHelper::PASTEE.submit_simple("Summary of #{category} members.", paste_contents)
        return "http://paste.ee/p/#{id}"
      end
    end
  end
end
