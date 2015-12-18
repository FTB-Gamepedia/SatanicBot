require 'cinch'
require 'string-utility'

module Plugins
  module Commands
    class EightBall
      include Cinch::Plugin

      match(/8ball/i)

      # Gets a random fortune and says it in chat.
      # @param msg [Cinch::Message] The message.
      def execute(msg)
        path = "#{Dir.pwd}/src/info/8ball.txt"
        msg.reply(StringUtility.random_line(path))
      end
    end
  end
end
