require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class AddQuote < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      match(/addquote (.+)/i)

      DOC = 'Adds a quote to the quote list. Op-only. 1 arg: $addquote <quote>'.freeze
      Variables::NonConstants.add_command('addquote', DOC)

      # Adds a quote to the quote list, for $randquote.
      # @param msg [Cinch::Message]
      # @param quote [String] The quote's text.
      def execute(msg, quote)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
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

        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end
    end
  end
end
