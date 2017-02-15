require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class SubCategoryMembers < AuthorizedCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Gets a comprehensive summary of all category members, their subcategories, and their members. Use ' \
                'this command with caution, as it will take a long time to process. Will upload the final result to ' \
                'Pastee. Op-only. 1 arg: $subcategorymembers <top category>',
          plugin_name: 'subcategorymembers')
      match(/subcategorymembers (.+)/i)

      # Gets a hash containing all of the category's members, subcategories,
      #   their members, their subcategories, etc. recursively.
      # @param butt [MediaWiki::Butt] The butt to use for the wiki queries.
      # @param category [String] The category to start at.
      # @return [Hash] The hash.
      def get_members(butt, category)
        subcats = butt.get_subcategories(category)
        members = butt.get_category_members(category)
        ret = {
          category => {
            members: [],
            subcats: []
          }
        }
        members.each do |member|
          ret[category][:members] << member
        end
        subcats.each do |cat|
          ret[category][:subcats] << get_members(butt, cat)
        end
        ret
      end

      # Forms the formatted string based on the hash from {#get_members}.
      # @param hash [Hash] The hash from {#get_members}.
      # @param level [Int] The header level currently at. This should pretty
      #   much always be 1 in normal calls, because it recursively increments
      #   it.
      # @return [String] The end string to be published on Pastee.
      def create_paste_contents(hash, level)
        contents = ''
        contents = "Comprehensive summary of #{hash.keys[0]}'s subcats.\n\n## #{hash.keys[0]}\n" if level == 1
        hash.each do |_, h|
          asterisks = '*' * level
          unless h[:members].empty?
            members_string = h[:members].join("\n#{asterisks} ")
            contents << "#{asterisks} #{members_string}\n"
          end

          unless h[:subcats].empty?
            h[:subcats].each do |h2|
              contents << "#{asterisks} #{h2.keys[0]}\n"
              contents << create_paste_contents(h2, level + 1)
            end
          end

          contents << "\n\n"
        end

        contents
      end

      # Creates a massive comprehensive summary of the subcategories of any
      #   given category on the wiki, and puts it on Pastee. The comprehensive
      #   summary includes a list of all category members, subcategories, their
      #   members, etc.
      # @param msg [Cinch::Message]
      # @param category [String] The top category.
      def execute(msg, category)
        category = "Category:#{category}" if /^Category:/ !~ category
        butt = LittleHelper.init_wiki
        paste_hash = get_members(butt, category)
        paste_contents = create_paste_contents(paste_hash, 1)
        id = LittleHelper::PASTEE.submit(paste_contents, "Summary of #{category} subcats.")
        msg.reply("http://paste.ee/p/#{id}")
      end
    end
  end
end
