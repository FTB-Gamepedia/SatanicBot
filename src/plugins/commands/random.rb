require 'cinch'
require 'literate_randomizer'

module Plugins
  module Commands
    module Random
      class Word
        include Cinch::Plugin

        match(/word/i)

        def execute(msg)
          msg.reply(LiterateRandomizer.word)
        end
      end

      class Sentence
        include Cinch::Plugin

        match(/sentence/i)

        def execute(msg)
          msg.reply(LiterateRandomizer.sentence)
        end
      end
    end
  end
end
