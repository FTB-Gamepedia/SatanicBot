require 'literate_randomizer'
require 'string-utility'
require 'array_utility'
require_relative 'base_command'

module Plugins
  module Commands
    class Random < BaseCommand
      using StringUtility
      using ArrayUtility

      class RandomWord < Random
        def initialize
          super(:randword, 'Outputs a random word. No args.', 'randword')
        end

        # Gets a random word that has not been said in the channel within the past
        #   5 calls.
        def execute(event)
          @last_words ||= []
          word = LiterateRandomizer.word
          word = LiterateRandomizer.word while @last_words.include?(word)
          @last_words.prepend_capped(word, 5)
          return word
        end
      end

      class RandomSentence < Random
        def initialize
          super(:randsentence, 'Outputs a random sentence. No args.')
        end

        # Gets a random sentence that has not been said in the channel within the
        #   past 5 calls.
        def execute(event)
          @last_sentences ||= []
          sentence = LiterateRandomizer.sentence
          sentence = LiterateRandomizer.sentence while @last_sentences.include?(sentence)
          @last_sentences.prepend_capped(sentence, 5)
          return sentence
        end
      end

      class RandomQuote < Random
        def initialize
          super(:randquote, 'Outputs a random quote. No args.')
        end

        # Gets a random quote that has not been said in the channel within the
        #   past 5 calls.
        def execute(event, args)
          quotes = Variables::NonConstants.get_quotes
          quote = quotes.sample
          @last_quotes ||= []
          quote = quotes.sample while @last_quotes.include?(quote)
          @last_quotes.prepend_capped(quote, 5)
          return quote
        end
      end

      class RandomNumber < Random
        def initialize
          super(:randnumber, 'Outputs a random number. 1 optional arg, defaults to 100.', 'randnumber [max]')
          @attributes[:min_args] = 0
          @attributes[:max_args] = 1
        end

        # Gets a random number that has not been said in the channel within the past 5 calls.
        def execute(event, args)
          max = args.empty? ? 100 : args[0].to_i
          @last_numbers ||= []
          number = rand(max)
          number = rand(max) while @last_numbers.include?(number)
          @last_numbers.prepend_capped(number, 5)
          return number.to_s.separate
        end
      end

      class Motivate < Random
        def initialize
          super(:motivate, 'Outputs a motivational message. 1 optional arg, defaults to command sender.', 'motivate [user]')
          @attributes[:min_args] = 0
          @attributes[:max_args] = 1
        end

        # Gets a random motivational statement for the provided user
        def execute(event, args)
          if args.empty? || event.channel.private?
            target = event.author
          else
            matching_users = event.channel.users.select { |u| u.display_name == args[0] }
            target = matching_users.any? ? matching_users[0] : event.author
          end

          @last_motivation ||= []

          line = StringUtility.random_line(Variables::Constants::MOTIVATE_PATH)
          while @last_motivation.include?(line)
            line = StringUtility.random_line(Variables::Constants::MOTIVATE_PATH)
          end
          @last_motivation.prepend_capped(line, 5)

          return "#{line.chomp}, #{target.mention}"
        end
      end
    end
  end
end
