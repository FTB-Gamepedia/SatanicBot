require 'cinch'

module Plugins
  module Commands
    class RefreshQuotes
      include Cinch::Plugin
      match(/refreshquotes/)

      DOC = 'Refreshes the quote list. Not necessary when adding quotes, ' \
            'as that will automatically append to the list.'.freeze
      Variables::NonConstants.add_command('refreshquotes', DOC)

      def execute(msg)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        Variables::NonConstants.get_quotes(true)
        msg.reply('Finished refreshing quotes.')
      end
    end
  end
end
