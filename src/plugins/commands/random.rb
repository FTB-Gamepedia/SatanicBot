require 'cinch'
require 'literate_randomizer'
require 'string-utility'
require 'array_utility'

module Plugins
  module Commands
    class Random
      include Cinch::Plugin
      using StringUtility
      using ArrayUtility

      match(/randword/i, method: :random_word)
      match(/randsentence/i, method: :random_sentence)
      match(/randquote/i, method: :random_quote)
      match(/randnum$/i, method: :random_number)
      match(/randnum (\d+)/i, method: :random_number_max)
      match(/motivate$/i, method: :motivate_you)
      match(/motivate (.+)/i, method: :motivate_else)

      def random_word(msg)
        word = LiterateRandomizer.word
        @last_words = [] if @last_words.nil?
        word = LiterateRandomizer.word while @last_words.include?(word)
        @last_words.prepend_capped(word, 5)
        msg.reply(word)
      end

      def random_sentence(msg)
        sentence = LiterateRandomizer.sentence
        @last_sentences = [] if @last_sentences.nil?
        sentence = LiterateRandomizer.sentence \
          while @last_sentences.include?(sentence)
        @last_sentences.prepend_capped(sentence, 5)
        msg.reply(sentence)
      end

      def random_quote(msg)
        quote = StringUtility.random_line(Variables::Constants::QUOTE_PATH)
        @last_quotes = [] if @last_quotes.nil?
        while @last_quotes.include?(quote)
          quote = StringUtility.random_line(Variables::Constants::QUOTE_PATH)
        end
        @last_quotes.prepend_capped(quote, 5)
        msg.reply(quote)
      end

      def random_number(msg)
        number = rand(100)
        @last_numbers = [] if @last_numbers.nil?
        number = rand(100) while @last_numbers.include?(number)
        @last_numbers.prepend_capped(number, 5)
        msg.reply(number.to_s)
      end

      def random_number_max(msg, maximum)
        number = rand(maximum.to_i)
        @last_numbers = [] if @last_numbers.nil?
        number = rand(maximum.to_i) while @last_numbers.include?(number)
        @last_numbers.prepend_capped(number, 5)
        number.to_s.separate if number > 999
        msg.reply(number)
      end

      def motivate_you(msg)
        line = StringUtility.random_line(Variables::Constants::MOTIVATE_PATH)
        @last_motivation = [] if @last_motivation.nil?
        line = StringUtility.random_line(Variables::Constants::MOTIVATE_PATH) \
          while @last_motivation.include?(line)
        @last_motivation.prepend_capped(line, 5)
        msg.reply("#{line}, #{msg.user.nick}")
      end

      def motivate_else(msg, user)
        if msg.channel.has_user?(user)
          line = StringUtility.random_line(Variables::Constants::MOTIVATE_PATH)
          @last_motivation = [] if @last_motivation.nil?
          line = StringUtility.random_line(Variables::Constants::MOTIVATE_PATH)\
            while @last_motivation.include?(line)
          @last_motivation.prepend_capped(line, 5)
          msg.reply("#{line}, #{user}")
        else
          motivate_you(msg)
        end
      end
    end
  end
end
