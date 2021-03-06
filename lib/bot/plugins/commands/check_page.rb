require 'cinch'
require 'string-utility'
require 'isgd'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class CheckPage < BaseCommand
      using StringUtility
      include Cinch::Plugin
      include Plugins::Wiki
      ignore_ignored_users

      set(help: 'Checks if a page exists. 1 arg: $checkpage <page name>', plugin_name: 'checkpage')
      match(/checkpage (.+)/i)

      # Checks whether the page exists on the wiki.
      # @param msg [Cinch::Message]
      # @param page [String] The page to check.
      def execute(msg, page)
        page.spacify!
        is_redir = wiki.page_redirect?(page)
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
