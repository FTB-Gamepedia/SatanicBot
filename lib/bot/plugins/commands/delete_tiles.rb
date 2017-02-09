require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class DeleteTiles < AuthorizedCommand
      include Cinch::Plugin
      ignore_ignored_users

      match(/deletetiles ([\d+\|]+)/i)

      doc = 'Deletes a set of Tilesheet tiles. 1 Argument: pipe separated list of IDs.'
      Variables::NonConstants.add_command('deletetiles', doc)

      def execute(msg, ids)
        butt = LittleHelper.init_wiki
        # TODO: Finish up MediaWiki::Butt extension stuff.
        params = {
          action: 'deletetiles',
          tsids: ids,
          tstoken: butt.get_token('edit')
        }
        response = butt.post(params)
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
