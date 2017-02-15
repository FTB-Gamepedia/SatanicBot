require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class AddQuote < AuthorizedCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Adds a quote to the quote list. Op-only. 1 arg: $addquote <quote>', plugin_name: 'addquote')
      match(/addquote (.+)/i)

      # Adds a quote to the quote list, for $randquote.
      # @param msg [Cinch::Message]
      # @param quote [String] The quote's text.
      def execute(msg, quote)
        butt = LittleHelper.init_wiki
        # TODO: See random
        quotes = butt.get_text('User:SatanicBot/NotGoodEnoughForENV/Quotes').split("\n")
        quotes.delete('</nowiki>')
        quotes << quote
        quotes << '</nowiki>'
        begin
          edit = butt.edit('User:SatanicBot/NotGoodEnoughForENV/Quotes', quotes.join("\n"))
          if edit
            Variables::NonConstants.append_quote(quote)
            msg.reply('Added to the quote list'.freeze)
          else
            msg.reply('Failed! There was no change to the page.')
          end
        rescue EditError => e
          msg.reply("Failed! Error code: #{e.message}")
        end
      end
    end
  end
end
