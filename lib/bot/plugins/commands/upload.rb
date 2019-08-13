require 'cinch'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class Upload < AuthorizedCommand
      include Cinch::Plugin
      include Plugins::Wiki
      ignore_ignored_users

      set(help: 'Uploads a web file to the wiki. Op-only. 2 args: $upload <url to upload> <filename to upload to>',
          plugin_name: 'upload')
      match(/upload (.*) (.*)/)

      # Uploads a file to the wiki.
      # @param msg [Cinch::Message]
      # @param url [String] The URL to upload.
      # @param filename [String] The file's name on the wiki.
      def execute(msg, url, filename)
        begin
          upload = wiki.upload(url, filename)
        rescue MediaWiki::Butt::UploadInvalidFileExtError => e
          msg.reply('Invalid file extension. Failed to upload!')
        rescue MediaWiki::Butt::EditError => e
          msg.reply("General error: #{e.message}")
        end

        if upload
          msg.reply('Uploaded the file to the wiki!'.freeze)
        else
          msg.reply('Failed to upload!')
        end
      end
    end
  end
end
