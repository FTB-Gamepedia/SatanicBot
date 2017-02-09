require 'fishbans'
require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class BanInfo < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      match(/banned (.+)/i, method: :execute)
      match(/banned$/i, method: :do_self)

      DOC = 'Gets whether or not the user is banned on a Minecraft server. ' \
            '1 optional arg: $banned <user> If there is no arg provided, ' \
            "the user's nickname will be used.".freeze
      Variables::NonConstants.add_command('banned', DOC)

      # Gets Minecraft server ban information from Fishbans.
      # @param msg [Cinch::Message]
      # @param username [String] The username to check.
      def execute(msg, username)
        bans = Fishbans.get_total_bans(username)
        if bans.is_a?(Fixnum)
          # A ternary would be illogical here for length.
          message =
            if bans > 0
              "#{username} has been banned! What a loser! They've been banned #{bans} times!"
            else
              "#{username} has not been banned! What a gentle person!"
            end
        else
          message = "Error: #{bans}"
        end

        msg.reply(message)
      end

      def do_self(msg)
        execute(msg, msg.user.nick)
      end
    end
  end
end
