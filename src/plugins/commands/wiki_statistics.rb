require 'cinch'

module Plugins
  module Commands
    class WikiStatistics
      include Cinch::Plugin

      match(/stats$/i, method: :get_all)
      match(/stats (.+)/i, method: :get_one)

      def get_all(msg)
        butt = LittleHelper.init_wiki
        stats = butt.get_statistics
        pages = stats['pages']
        articles = stats['articles']
        edits = stats['edits']
        images = stats['images']
        users = stats['users']
        activeusers = stats['activeusers']
        admins = stats['admins']

        msg.reply("Pages: #{pages} | Articles: #{articles} | Edits: #{edits}" \
                  "Images: #{images} | Users: #{users} | Active users: " \
                  "#{activeusers} | Admins: #{admins}")
      end

      def get_one(msg, prop)
        valid_properties = [
          'pages',
          'articles',
          'edits',
          'images',
          'users',
          'activeusers',
          'admins'
        ]

        if valid_properties.include?(prop.downcase)
          butt = LittleHelper.init_wiki
          stats = butt.get_statistics
          msg.reply("#{prop.capitalize}: #{stats[prop]}")
        else
          msg.reply('That is not a valid property, getting general statistics.')
          get_all(msg)
        end
      end
    end
  end
end
