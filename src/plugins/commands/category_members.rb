require 'cinch'

module Plugins
  module Commands
    class CategoryMembers
      include Cinch::Plugin

      match(/categorymembers (.+)/i)

      doc = 'Gets a comprehensive summary of all category members, ' \
            'organized by the other categories of each member. Use this ' \
            'command with caution, as it will take a very long time to ' \
            'process. Uploads the summary to Pastee. 1 arg: ' \
            '$categorymembers <top category>'
      Variables::NonConstants.add_command('categorymembers', doc)

      # Creates a massive comprehensive summary of the category members of any
      #   given category on the wiki, and puts it on Pastee. The comprehensive
      #   summary includes a list of all category members, and those members
      #   organized by their other categories.
      # @param msg [Cinch::Message]
      # @param category [String] The top category.
      def execute(msg, category)
        authedusers = Variables::NonConstants.get_authenticated_users
        category = "Category:#{category}" if /^Category:/ !~ category
        if authedusers.include?(msg.user.authname)
          butt = LittleHelper.init_wiki
          members = butt.get_category_members(category, 5000)
          paste_hash = {}
          members.each do |page|
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
          pastee = LittleHelper.init_pastee
          id = pastee.submit(paste_contents, "Summary of #{category} members.")
          msg.reply("http://paste.ee/p/#{id}")
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end
    end
  end
end
