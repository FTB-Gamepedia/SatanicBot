require 'cinch'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class DeleteTiles < AuthorizedCommand
      include Cinch::Plugin
      include Plugins::Wiki
      ignore_ignored_users

      set(help: 'Deletes a set of Tilesheet tiles. 1 arg: pipe separated list of IDs.', plugin_name: 'deletetiles')
      match(/deletetiles ([\d+\|]+)/i)

      def execute(msg, ids)
        # TODO: Finish up MediaWiki::Butt extension stuff.
        params = {
          action: 'deletetiles',
          tsids: ids,
          tstoken: wiki.get_token('csrf')
        }
        response = wiki.post(params)
        failures = ids.split('|')
        response['edit']['deletetiles'].each_key do |id|
          failures.delete(id)
        end

        if failures.empty?
          msg.reply('Successfully deleted all provided tiles.')
        else
          msg.reply("Failed to delete #{failures.join(', ')}")
        end
      end
    end
  end
end
