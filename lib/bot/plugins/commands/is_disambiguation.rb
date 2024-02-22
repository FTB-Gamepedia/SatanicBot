require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class IsDisambiguation < BaseCommand
      include Plugins::Wiki

      def initialize
        super(:'dis?', 'Returns whether the provided page is a disambiguation page.', 'dis? <page>')
      end

      def execute(event, args)
        page_name = args.join(' ')
        categories = wiki.get_categories_in_page(page_name)
        if categories
          a = categories.include?('Category:Disambiguation pages') ? 'a' : 'not a'
          "#{page_name} is #{a} disambiguation page."
        else
          "#{page_name} is not a page."
        end
      end
    end
  end
end
