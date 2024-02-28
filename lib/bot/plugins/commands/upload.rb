require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class Upload < AuthorizedCommand
      include Plugins::Wiki
      
      def initialize
        super(:upload, 'Uploads a web file to the wiki.', 'upload <url> <desired file name>')
      end

      def execute(event, args)
        url = args[0]
        filename = args[1..-1].join(' ')
        begin
          upload = wiki.upload(url, filename)
        rescue MediaWiki::Butt::UploadInvalidFileExtError => e
          return 'Invalid file extension. Failed to upload!'
        rescue MediaWiki::Butt::EditError => e
          return "General error: #{e.message}"
        end

        return upload ? 'Uploaded the file to the wiki!'.freeze  : 'Failed to upload!'
      end
    end
  end
end
