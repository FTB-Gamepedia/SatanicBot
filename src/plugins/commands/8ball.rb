require 'cinch'
require 'string-utility'

module Plugins
  module Commands
    class EightBall
      include Cinch::Plugin

      match(/8ball/i)

      def execute(msg)
        path = "#{Dir.pwd}/src/info/8ball.txt"
        msg.reply(StringUtility.random_line(path))
      end
    end
  end
end
