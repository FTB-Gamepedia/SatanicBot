require 'cinch'
require 'curb'

module Plugins
  module Commands
    class Drama
      include Cinch::Plugin

      match(/drama/i)

      DOC = 'Gets a random act of Minecraft drama! No args.'.freeze
      Variables::NonConstants.add_command('drama', DOC)

      def execute(msg)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        msg.reply(Curl.get('http://mc-drama.herokuapp.com/raw'.freeze).body_str)
      end
    end
  end
end
