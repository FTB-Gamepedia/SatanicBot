require 'cinch'

module Plugins
  module Commands
    class RefreshQuotes
      include Cinch::Plugin
      match(/refreshquotes/)

      doc = 'Refreshes the quote list. Not necessary when adding quotes, as that will automatically append to the list.'
      Variables::NonConstants.add_command('refreshquotes', doc)

      def execute(msg)
        Variables::NonConstants.get_quotes(true)
        msg.reply('Finished refreshing quotes.')
      end
    end
  end
end