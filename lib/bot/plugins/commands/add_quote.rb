require 'cinch'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class AddQuote < AuthorizedCommand
      include Cinch::Plugin
      include Plugins::Wiki
      ignore_ignored_users

      set(help: 'Adds a quote to the quote list. Op-only. 1 arg: $addquote <quote>', plugin_name: 'addquote')
      match(/addquote (.+)/i)

      # Adds a quote to the quote list, for $randquote.
      # @param msg [Cinch::Message]
      # @param quote [String] The quote's text.
      def execute(msg, quote)
        edit("User:#{Variables::Constants::WIKI_USERNAME}/NotGoodEnoughForENV/Quotes", msg) do |text|
          # TODO: See random
          quotes = text.split("\n")
          quotes.delete('</nowiki>')
          quotes << quote
          quotes << '</nowiki>'
          {
            text: quotes.join("\n"),
            success: Proc.new do
              Variables::NonConstants.append_quote(quote)
              'Added to the quote list'
            end,
            fail: Proc.new { 'Failed! There was no change to the page.' },
            error: Proc.new { |e| "Failed! Error code: #{e.message}" }
          }
        end
      end
    end
  end
end
