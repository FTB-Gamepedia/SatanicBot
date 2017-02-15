require 'cinch'
require 'curb'
require_relative 'base_command'

module Plugins
  module Commands
    class Drama < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Gets a random act of Minecraft drama. No args.', plugin_name: 'drama')
      match(/drama/i)

      def execute(msg)
        msg.reply(Curl.get('http://mc-drama.herokuapp.com/raw'.freeze).body_str)
      end
    end
  end
end
