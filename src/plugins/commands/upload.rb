require 'cinch'

module Plugins
  module Commands
    class Upload
      include Cinch::Plugin

      match(/upload (.*) (.*)/)

      def execute(msg, url, filename)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          butt = LittleHelper.init_wiki
          upload = butt.upload(url, filename)
          if upload
            msg.reply('Uploaded the file to the wiki!')
          else
            msg.reply("Possibly failed! Error warning: #{upload}")
          end
        else
          msg.reply('You must be authenticated for this action.')
        end
      end
    end
  end
end
