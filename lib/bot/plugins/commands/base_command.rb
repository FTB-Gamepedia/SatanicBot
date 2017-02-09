require 'cinch'

module Cinch
  module Plugin
    module ClassMethods
      def ignore_ignored_users
        hook(:pre, for: [:match])
      end
    end
  end

  class User
    # @return [Boolean] Whether this user should be ignored by the bot.
    def ignored?
      Variables::Constants::IGNORED_USERS.include?(nick)
    end

    # @return [Boolean] Whether this user is logged into the bot.
    def authorized?
      Variables::NonConstants.get_authenticated_users.include?(authname)
    end

    # @return [Boolean] Whether this user is the owner of the bot.
    def owns_bot?
      authname == Variables::Constants::OWNER
    end
  end
end

module Plugins
  module Commands
    class BaseCommand
      def hook(msg)
        !msg.user.ignored?
      end
    end

    class AuthorizedCommand < BaseCommand
      def hook(msg)
        authorized = msg.user.authorized?
        msg.reply(Variables::Constants::LOGGED_IN) unless authorized
        authorized
      end
    end

    class OwnerCommand < BaseCommand
      def hook(msg)
        is_owner = msg.user.owns_bot?
        msg.reply(Variables::Constants::OWNER_ONLY) unless is_owner
        is_owner
      end
    end
  end
end
