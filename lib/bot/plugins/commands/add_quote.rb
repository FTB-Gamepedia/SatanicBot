require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class AddQuote < AuthorizedCommand
      include Plugins::Wiki

      def initialize
        super(:addquote, 'Adds a quote to the quote list. Either provide a quote as an argument, or reply to the message to add.', 'addquote [quote]')
      end

      def execute(event, args)
        if event.message.reply?
          quote = "#{event.message.referenced_message.author.nick || event.message.referenced_message.author.username}: #{event.message.referenced_message.text}"
        else
          quote = args.join(' ')
        end
        if !quote.empty?
          edit("User:#{Variables::Constants::WIKI_USERNAME}/NotGoodEnoughForENV/Quotes", event) do |text|
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
        else
          return 'No quote provided.'
        end
      end
    end
  end
end
