require 'cinch'
require 'string-utility'

module Plugins
  module Commands
    class CheckPage
      using StringUtility
      include Cinch::Plugin

      match(/checkpage (.+)/i)

      def execute(msg, page)
        butt = LittleHelper.init_wiki
        page = page.spacify
        if butt.get_text(page).nil?
          msg.reply("#{page} does not exist on the FTB Wiki.")
        else
          link = "http://ftb.gamepedia.com/#{page.underscorify}"
          msg.reply("#{page} exists: #{link}")
        end
      end
    end
  end
end
