require 'mediawiki/exceptions'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class NewVanilla < AuthorizedCommand
      include Plugins::Wiki

      def initialize
        super(:newvanilla, 'Creates a new page for a Vanilla thing. Automatically disambiguates.', 'newvanilla <page> | <type>')
        @attributes[:min_args] = 3
      end

      def execute(msg, args)
        arg_match = args.join(' ').match(/(.+) \| (.+)/)
        page = arg_match[1]
        page = page.end_with?('(Vanilla)') ? page : "#{page} (Vanilla)"
        type = arg_match[2]
        if wiki.get_text(page).nil?
          text = "{{Vanilla|type=#{type}}}\n\n<languages />"
          begin
            wiki.create_page(page, text, summary: 'New vanilla page.'.freeze)
          rescue MediaWiki::Butt::EditError => e
            return "Failed! Error code: #{e.message}"
          end

          return "Successfully created #{page}."
        else
          return 'That page already exists.'.freeze
        end
      end
    end
  end
end
