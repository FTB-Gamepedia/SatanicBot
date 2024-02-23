require 'discordrb'
require_relative '../base_plugin'

module Discordrb
  class User
    # @return [Boolean] Whether this user should be ignored by the bot.
    def ignored?
      Variables::Constants::IGNORED_USERS.include?(username)
    end

    # @return [Boolean] Whether this user is the owner of the bot.
    def owns_bot?
      username == Variables::Constants::OWNER
    end
  end
end

module Plugins
  module Commands
    class BaseCommand < BasePlugin
      attr_reader :name
      attr_reader :attributes

      # @param name [Symbol] The name of the command, how it is called
      # @param help_msg [String] Output of $help command.
      # @param usage_msg [String] The "usage" section of the help command. Defaults to name converted to a String.
      #   Use to define command arguments, with <> being required and [] being optional. For example,
      #   'command <arg1> <arg2> [optional3]'
      def initialize(name, help_msg, usage_msg = nil)
        @name = name
        @attributes = {
          description: help_msg,
          usage: usage_msg || name.to_s
        }
      end
    end

    class AuthorizedCommand < BaseCommand
      def initialize(name, help_msg, usage_msg = nil)
        super(name, help_msg, usage_msg)
        @attributes[:required_roles] = [ Variables::Constants::AUTHORIZED_ROLE_ID ]
      end
    end

    class OwnerCommand < BaseCommand
      ERROR_MSG = 'This command is for the owner only.'.freeze

      def can_execute?(event)
        return false unless super(event)
        is_owner = event.author.owns_bot?
        event.send_message(ERROR_MSG) unless is_owner
        is_owner
      end
    end
  end
end
