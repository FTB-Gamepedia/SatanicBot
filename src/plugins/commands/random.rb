require 'cinch'
require 'literate_randomizer'
require 'string-utility'

module Plugins
  module Commands
    class Random
      include Cinch::Plugin
      using StringUtility

      match(/randword/i, method: :random_word)
      match(/randsentence/i, method: :random_sentence)
      match(/randquote/i, method: :random_quote)
      match(/randnum$/i, method: :random_number)
      match(/randnum (\d+)/i, method: :random_number_max)

      def random_word(msg)
        msg.reply(LiterateRandomizer.word)
      end

      def random_sentence(msg)
        msg.reply(LiterateRandomizer.sentence)
      end

      def random_quote(msg)
        path = "#{Dir.pwd}/src/info/ircquotes.txt"
        msg.reply(StringUtility.random_line(path))
      end

      def random_number(msg)
        msg.reply(rand(100).to_s)
      end

      def random_number_max(msg, maximum)
        num = rand(maximum.to_i).to_s
        num = num.separate if num.to_i > 999
        msg.reply(num)
      end
    end
  end
end
