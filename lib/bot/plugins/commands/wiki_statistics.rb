require 'cinch'
require 'string-utility'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class WikiStatistics < BaseCommand
      include Cinch::Plugin
      include Plugins::Wiki
      using StringUtility
      ignore_ignored_users

      VALID_PROPERTIES = %w(pages articles edits images users activeusers admins).freeze

      set(help: "Gives wiki stats. 1 optional arg: $stats [type], where type can be any of: #{VALID_PROPERTIES.join ('; ')}",
          plugin_name: 'stats')
      match(/stats$/i, method: :get_all)
      match(/stats (.+)/i, method: :get_one)

      # Gets all statistics for the wiki, including number of pages, articles,
      #   edits, images, users, admins, and active users.
      # @param msg [Cinch::Message]
      def get_all(msg)
        stats = wiki.get_statistics
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
        if VALID_PROPERTIES.include?(prop.downcase)
          stats = wiki.get_statistics
          stat = stats[prop].to_s.separate
          msg.reply("#{prop.capitalize}: #{stat}")
        else
          msg.reply('That is not a valid property, getting general statistics.'.freeze)
          get_all(msg)
        end
      end
    end
  end
end
