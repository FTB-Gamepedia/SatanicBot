require 'cinch'

module Plugins
  module Commands
    class Upload
      include Cinch::Plugin

      match(/upload (.*) (.*)/)

      doc = 'Uploads a web file to the wiki. Op-only. 2 args: $upload ' \
            '<url> <filename>'
      Variables::NonConstants.add_command('upload', doc)

      # Uploads a file to the wiki.
      # @param msg [Cinch::Message]
      # @param url [String] The URL to upload.
      # @param filename [String] The file's name on the wiki.
      def execute(msg, url, filename)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          butt = LittleHelper.init_wiki
          upload = butt.upload(url, filename)
          if upload
            msg.reply('Uploaded the file to the wiki!'.freeze)
          else
            msg.reply("Possibly failed! Error warning: #{upload}")
          end
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end
    end
  end
end
