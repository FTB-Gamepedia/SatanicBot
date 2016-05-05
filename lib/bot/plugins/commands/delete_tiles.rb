require 'cinch'

module Plugins
  module Commands
    class DeleteTiles
      include Cinch::Plugin

      match(/deletetiles ([\d+\|]+)/i)

      doc = 'Deletes a set of Tilesheet tiles. 1 Argument: pipe separated list of IDs.'
      Variables::NonConstants.add_command('deletetiles', doc)

      def execute(msg, ids)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
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
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end
    end
  end
end
