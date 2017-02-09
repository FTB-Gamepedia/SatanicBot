require 'cinch'
require 'string-utility'
require 'isgd'
require_relative 'base_command'

module Plugins
  module Commands
    class CheckPage < BaseCommand
      using StringUtility
      include Cinch::Plugin
      ignore_ignored_users

      match(/checkpage (.+)/i)

      DOC = 'Checks if a page exists. 1 arg: $checkpage <page>'.freeze
      Variables::NonConstants.add_command('checkpage', DOC)

      # Checks whether the page exists on the wiki.
      # @param msg [Cinch::Message]
      # @param page [String] The page to check.
      def execute(msg, page)
        butt = LittleHelper.init_wiki
        page = page.spacify
        is_redir = butt.page_redirect?(page)
        link = ISGD.shorten("http://ftb.gamepedia.com/#{page.underscorify}")
        if is_redir.nil?
          msg.reply("#{page} does not exist on FTB Gamepedia.")
        elsif is_redir
          msg.reply("#{page} exists on the wiki as a redirect: #{link}")
        elsif !is_redir
          msg.reply("#{page} exists: #{link}")
        end
      end
    end
  end
end
