require 'string-utility'
require_relative 'base_command'

module Plugins
  module Commands
    class Editathon < BaseCommand
      include Cinch::Plugin
      using StringUtility
      ignore_ignored_users

      set(help: 'Provides information for the current, upcoming, or most recent editathon.', plugin_name: 'editathon')
      match(/editathon/i)

      FORMAT = '%B %e %Y %H:%M:%S UTC'.freeze

      def execute(msg)
        butt = LittleHelper.init_wiki
        newest_editathon = butt.get_category_members('Category:Editathons').max do |a, b|
          butt.first_edit_timestamp(a) <=> butt.first_edit_timestamp(b)
        end
        text = butt.get_text(newest_editathon)
        dates = text.scan(/<!--\nstart: (.+)\nend: (.+)\n-->/).flatten
        start_date = Time.parse(dates[0]).utc
        end_date = Time.parse(dates[1]).utc
        current = Time.now.utc
        url = "https:#{butt.get_article_path(newest_editathon.underscorify)}"
        if current.in_progress?(start_date, end_date)
          msg.reply("Current editathon: #{url}")
        elsif current < start_date
          msg.reply("Upcoming editathon: #{url} starting on #{start_date.strftime(FORMAT)}")
        elsif current < end_date
          msg.reply("Past editathon: #{url} ended on #{end_date.strftime(FORMAT)}")
        end
      end
    end
  end
end
