require 'cinch'

module Plugins
  module Commands
    class AddQuote
      include Cinch::Plugin

      match(/addquote (.+)/i)

      DOC = 'Adds a quote to the quote list. Op-only. 1 arg: $addquote <quote>'.freeze
      Variables::NonConstants.add_command('addquote', DOC)

      # Adds a quote to the quote list, for $randquote.
      # @param msg [Cinch::Message]
      # @param quote [String] The quote's text.
      def execute(msg, quote)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          butt = LittleHelper.init_wiki
          # TODO: See random
          quotes = butt.get_text('User:SatanicBot/NotGoodEnoughForENV/Quotes').split("\n")
          quotes.delete('</nowiki>')
          quotes << quote
          quotes << '</nowiki>'
          edit = butt.edit('User:SatanicBot/NotGoodEnoughForENV/Quotes', quotes.join("\n"))
          if edit.is_a?(Fixnum)
            Variables::NonConstants.append_quote(quote)
            msg.reply('Added to the quote list'.freeze)
          else
            msg.reply("Failed! Error code: #{edit}".freeze)
          end
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end
    end
  end
end
