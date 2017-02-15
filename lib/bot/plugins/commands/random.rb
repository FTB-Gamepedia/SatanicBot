require 'cinch'
require 'literate_randomizer'
require 'string-utility'
require 'array_utility'
require_relative 'base_command'

module Plugins
  module Commands
    class Random < BaseCommand
      include Cinch::Plugin
      using StringUtility
      using ArrayUtility
      ignore_ignored_users

      set(help: 'Outputs a random word. No args.', plugin_name: 'randword')
      set(help: 'Outputs a random sentence. No args.', plugin_name: 'randsentence')
      set(help: 'Outputs a random quote. No args.', plugin_name: 'randquote')
      set(help: 'Outputs a random number. 1 optional arg: $randnum [max], 100 is default.', plugin_name: 'randnum')
      set(help: 'Outputs a motivational message. 1 optional arg: $motivate [user], defaults to command sender.',
          plugin_name: 'motivate')
      match(/randword/i, method: :random_word)
      match(/randsentence/i, method: :random_sentence)
      match(/randquote/i, method: :random_quote)
      match(/randnum$/i, method: :random_number)
      match(/randnum (\d+)/i, method: :random_number_max)
      match(/motivate$/i, method: :motivate_you)
      match(/motivate (.+)/i, method: :motivate_else)

      # Gets a random word that has not been said in the channel within the past
      #   5 calls.
      # @param msg [Cinch::Message]
      def random_word(msg)
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
        sentence = LiterateRandomizer.sentence
        @last_sentences = [] if @last_sentences.nil?
        sentence = LiterateRandomizer.sentence while @last_sentences.include?(sentence)
        @last_sentences.prepend_capped(sentence, 5)
        msg.reply(sentence)
      end

      # Gets a random quote that has not been said in the channel within the
      #   past 5 calls.
      # @param msg [Cinch::Message]
      def random_quote(msg)
        quotes = Variables::NonConstants.get_quotes
        quote = quotes.sample
        @last_quotes = [] if @last_quotes.nil?
        quote = quotes.sample while @last_quotes.include?(quote)
        @last_quotes.prepend_capped(quote, 5)
        msg.reply(quote)
      end

      # Gets a random number with a cap of 100 that has not been said in the
      #   channel within the past 5 calls.
      # @param msg [Cinch::Message]
      def random_number(msg)
        random_number_max(msg, 100)
      end

      # Gets a random number that has not been said in the channel within the
      #   past 5 calls.
      # @param msg [Cinch::Message]
      # @param maximum [String] The integer cap.
      def random_number_max(msg, maximum)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
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
        motivate_else(msg, msg.user.nick)
      end

      # Gets a random motivational statement for the provided user.
      # @param msg [Cinch::Message]
      # @param user [String] The username to motivate.
      def motivate_else(msg, user)
        if !msg.channel? || msg.channel.has_user?(user)
          line = StringUtility.random_line(Variables::Constants::MOTIVATE_PATH)
          @last_motivation = [] if @last_motivation.nil?
          while @last_motivation.include?(line)
            line = StringUtility.random_line(Variables::Constants::MOTIVATE_PATH)
          end
          @last_motivation.prepend_capped(line, 5)
          msg.reply("#{line.chomp}, #{user}")
        else
          motivate_you(msg)
        end
      end
    end
  end
end
