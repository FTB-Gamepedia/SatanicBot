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

      word_doc = 'Outputs a random word. No args.'
      sentence_doc = 'Outputs a random sentence. No args.'
      quote_doc = 'Outputs a random quote. No args.'
      num_doc = 'Outputs a random number. 1 optional arg: $randnum <max>, ' \
                'when not set 100 will be used as the maximum.'
      motivate_doc = 'Motivates you or the user provided in the first arg. ' \
                     'If the user in the first arg is not in the channel, ' \
                     'I will motivate you instead <3'
      Variables::NonConstants.add_command('randword', word_doc)
      Variables::NonConstants.add_command('randsentence', sentence_doc)
      Variables::NonConstants.add_command('randquote', quote_doc)
      Variables::NonConstants.add_command('randnum', num_doc)
      Variables::NonConstants.add_command('motivate', motivate_doc)

      # Gets a random word that has not been said in the channel within the past
      #   5 calls.
      # @param msg [Cinch::Message]
      def random_word(msg)
        if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          return
        end
        word = LiterateRandomizer.word
        @last_words = [] if @last_words.nil?
        word = LiterateRandomizer.word while @last_words.include?(word)
        @last_words.prepend_capped(word, 5)
        msg.reply(word)
      end

      # Gets a random sentence that has not been said in the channel within the
      #   past 5 calls.
      # @param msg [Cinch::Message]
      def random_sentence(msg)
        if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          return
        end
        sentence = LiterateRandomizer.sentence
        @last_sentences = [] if @last_sentences.nil?
        sentence = LiterateRandomizer.sentence \
          while @last_sentences.include?(sentence)
        @last_sentences.prepend_capped(sentence, 5)
        msg.reply(sentence)
      end

      # Gets a random quote that has not been said in the channel within the
      #   past 5 calls.
      # @param msg [Cinch::Message]
      def random_quote(msg)
        if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          return
        end
        quote = StringUtility.random_line(Variables::Constants::QUOTE_PATH)
        @last_quotes = [] if @last_quotes.nil?
        while @last_quotes.include?(quote)
          quote = StringUtility.random_line(Variables::Constants::QUOTE_PATH)
        end
        @last_quotes.prepend_capped(quote, 5)
        msg.reply(quote)
      end

      # Gets a random number with a cap of 100 that has not been said in the
      #   channel within the past 5 calls.
      # @param msg [Cinch::Message]
      def random_number(msg)
        if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          return
        end
        random_number_max(msg, 100)
      end

      # Gets a random number that has not been said in the channel within the
      #   past 5 calls.
      # @param msg [Cinch::Message]
      # @param maximum [String] The integer cap.
      def random_number_max(msg, maximum)
        if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          return
        end
        number = rand(maximum.to_i)
        @last_numbers = [] if @last_numbers.nil?
        number = rand(maximum.to_i) while @last_numbers.include?(number)
        @last_numbers.prepend_capped(number, 5)
        number.to_s.separate if number > 999
        msg.reply(number)
      end

      # Gets a random motivational statement for the user who used the command.
      # @param msg [Cinch::Message]
      def motivate_you(msg)
        if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          return
        end
        motivate_else(msg, msg.user.nick)
      end

      # Gets a random motivational statement for the provided user.
      # @param msg [Cinch::Message]
      # @param user [String] The username to motivate.
      def motivate_else(msg, user)
        if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          return
        end
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
