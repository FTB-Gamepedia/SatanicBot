require 'cinch'

module Plugins
  module Commands
    class AddQuote
      include Cinch::Plugin

      match(/addquote (.+)/i)

      doc = 'Adds a quote to the quote list. Op-only. 1 arg: $addquote ' \
            '<quote>'
      Variables::NonConstants.add_command('addquote', doc)

      # Adds a quote to the quote list, for $randquote.
      # @param msg [Cinch::Message]
      # @param quote [String] The quote's text.
      def execute(msg, quote)
        if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          return
        end
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          butt = LittleHelper.init_wiki
          # TODO See random
          quotes = butt.get_text('User:SatanicBot/NotGoodEnoughForENV/Quotes').split("\n")
          quotes.delete('</nowiki>')
          quotes << quote
          quotes << '</nowiki>'
          edit = butt.edit('User:SatanicBot/NotGoodEnoughForENV/Quotes', quotes.join("\n"))
          if edit.is_a?(Fixnum)
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
