require 'string-utility'
require 'isgd'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class CheckPage < BaseCommand
      using StringUtility
      include Plugins::Wiki

      def initialize
        super(:checkpage, 'Checks if a page exists on the FTB Wiki.', 'checkpage <page>')
      end

      def execute(event, args)
        page = args.join(' ')
        page.spacify!
        is_redir = wiki.page_redirect?(page)
        # TODO: Change URL to be dynamic.
        link = no_embed(ISGD.shorten("https://ftb.fandom.com/#{page.underscorify}"))
        if is_redir.nil?
          "#{page} does not exist on the FTB Wiki."
        elsif is_redir
          "#{page} exists on the FTB Wiki as a redirect: #{link}"
        elsif !is_redir
          "#{page} exists: #{link}"
        end
      end
    end
  end
end
