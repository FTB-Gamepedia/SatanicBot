require 'discordrb'

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
    class BaseCommand
      attr_reader :name
      attr_reader :help_msg
      attr_reader :usage_msg
      attr_reader :args

      def initialize
        @args = {}
      end

      def can_execute?(event)
        !event.user.ignored? && !disabled?
      end

      def disabled?
        Variables::Constants::DISABLED_PLUGINS.include? self.class.name
      end
    end

    class AdminCommand < BaseCommand
      @@admin_role = nil

      def can_execute?(event)
        return false unless super(event)

        @@admin_role = event.server.roles.select { |r| r.name == Variables::Constants::ADMIN_ROLE_NAME }[0] if @@admin_role.nil?

        authorized = event.author.role? @@admin_role
        event.send_message("Only users in the #{@@admin_role.name} role can use this command.") unless authorized
        authorized
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
