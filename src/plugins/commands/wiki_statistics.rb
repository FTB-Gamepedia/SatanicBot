require 'cinch'
require 'string-utility'

module Plugins
  module Commands
    class WikiStatistics
      include Cinch::Plugin
      using StringUtility

      match(/stats$/i, method: :get_all)
      match(/stats (.+)/i, method: :get_one)

      # Gets all statistics for the wiki, including number of pages, articles,
      #   edits, images, users, admins, and active users.
      # @param msg [Cinch::Message]
      def get_all(msg)
        butt = LittleHelper.init_wiki
        stats = butt.get_statistics
        pages = stats['pages'].to_s.separate
        articles = stats['articles'].to_s.separate
        edits = stats['edits'].to_s.separate
        images = stats['images'].to_s.separate
        users = stats['users'].to_s.separate
        activeusers = stats['activeusers'].to_s.separate
        admins = stats['admins'].to_s.separate

        msg.reply("Pages: #{pages} | Articles: #{articles} | Edits: #{edits}" \
                  " | Images: #{images} | Users: #{users} | Active users: " \
                  "#{activeusers} | Admins: #{admins}")
      end

      # Gets a single statistic on the wiki.
      # @param msg [Cinch::Message]
      # @param prop [String] The property to get. Can be any of the following:
      #   pages, articles, edits, images, users, activeusers, or admins.
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
          stat = stats[prop].to_s.separate
          msg.reply("#{prop.capitalize}: #{stat}")
        else
          msg.reply('That is not a valid property, getting general statistics.')
          get_all(msg)
        end
      end
    end
  end
end
