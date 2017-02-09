require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class RefreshQuotes < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users
      match(/refreshquotes/)

      DOC = 'Refreshes the quote list. Not necessary when adding quotes, ' \
            'as that will automatically append to the list.'.freeze
      Variables::NonConstants.add_command('refreshquotes', DOC)

      def execute(msg)
        Variables::NonConstants.get_quotes(true)
        msg.reply('Finished refreshing quotes.')
      end
    end
  end
end
