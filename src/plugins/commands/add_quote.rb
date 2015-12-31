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
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          path = 'src/info/ircquotes.txt'
          file = File.open(File.expand_path(path, Variables::Constants::PWD),
                           'a')
          file.puts(quote)
          file.close
          msg.reply('Added to the quote list.')
        else
          msg.reply('You must be authenticated for this action.')
        end
      end
    end
  end
end
