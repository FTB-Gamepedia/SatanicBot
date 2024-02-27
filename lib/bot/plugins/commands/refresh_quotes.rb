require_relative 'base_command'

module Plugins
  module Commands
    class RefreshQuotes < BaseCommand
      def initialize
        super(:refreshquotes, 'Refreshes the quote list. Not necessary after adding quotes.')
      end

      def execute(event, args)
        Variables::NonConstants.get_quotes(true)
        return 'Finished refreshing quotes.'
      end
    end
  end
end
