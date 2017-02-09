require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class NumberGame < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      match(/game start$/i, method: :init)
      match(/game guess (\d+)/i, method: :guess)
      match(/game quit$/i, method: :quit)

      DOC = 'Number guessing game. Initialize with $game star. Then guess numbers with $game guess <number>. ' \
            'A game can be quit with $game quit'.freeze
      Variables::NonConstants.add_command('game', DOC)

      @started = false
      @random_number = nil
      @tries = nil
      @previous_difference = 0

      # Quits the number game if one has been started.
      # @param msg [Cinch::Message]
      def quit(msg)
        if @started
          msg.reply('Game exited.'.freeze)
          @started = false
          @random_number = nil
          @tries = nil
        else
          msg.reply('There is not game to exit.'.freeze)
        end
      end

      # Initializes a number game.
      # @param msg [Cinch::Message]
      def init(msg)
        msg.reply('Game starting! You have 5 tries! Submit an answer by using $game guess followed by a number!'.freeze)
        @started = true
        @random_number = rand(100)
        @tries = 0
      end

      # Checks if the number guessed is correct. It will state if the user's
      #   guess was warm or cold to the original number, and if they were warmer
      #   or colder than their previous guess.
      # @param msg [Cinch::Message]
      # @param num [String] The number to guess.
      def guess(msg, num)
        num = num.to_i
        if @started
          @tries += 1
          if @tries > 5
            msg.reply("Sorry, you have tried the maximum number of times. The random number was #{@random_number}")
            @started = false
            @tries = 0
            return
          end

          if @random_number == num
            msg.reply("Correct! You win a shitty cookie! It took you #{@tries} tries!")
            @started = false
            @tries = 0
            return
          end

          measure = @random_number / 5
          measures = [
            measure,
            measure * 2,
            measure * 3,
            measure * 4,
            measure * 5
          ]

          diff = num - @random_number
          diff = diff.abs

          if @tries == 1
            if num.between?(measures[4], @random_number + measures[4])
              msg.reply('You are on fire!'.freeze)
            elsif num.between?(measures[3], @random_number + measures[3])
              msg.reply('You are warm.'.freeze)
            elsif num.between?(measures[2], @random_number + measures[2])
              msg.reply('You are pretty neutral.'.freeze)
            elsif num.between?(measures[1], @random_number + measures[1])
              msg.reply('You are cold.'.freeze)
            elsif num.between?(measures[0], @random_number + measures[0])
              msg.reply('You are fucking freezing!'.freeze)
            end
          elsif diff < @previous_difference
            msg.reply('You are warmer.'.freeze)
          else
            msg.reply('You are colder.'.freeze)
          end

          @previous_difference = diff
        else
          msg.reply('You must start the game first.'.freeze)
        end
      end
    end
  end
end
