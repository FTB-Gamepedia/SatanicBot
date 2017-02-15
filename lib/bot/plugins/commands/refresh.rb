require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class RefreshQuotes < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Refreshes the quote list. Not necessary after adding quotes, as that automatically appends to the list.',
          plugin_name: 'refreshquotes')
      match(/refreshquotes/)

      def execute(msg)
        Variables::NonConstants.get_quotes(true)
        msg.reply('Finished refreshing quotes.')
      end
    end
  end
end
