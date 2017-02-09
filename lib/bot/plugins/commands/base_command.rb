require 'cinch'

module Cinch
  module Plugin
    module ClassMethods
      def ignore_ignored_users
        hook(:pre, for: [:match], method: :not_ignored_user?)
      end
    end
  end
end

module Plugins
  module Commands
    class BaseCommand
      # @param [Cinch::Message]
      # @return [Boolean] Whether the user who sent the message is ignored or not. (True if they are not ignored).
      def not_ignored_user?(msg)
        !Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
      end
    end

    class AuthorizedOnlyCommand < BaseCommand
      def not_igno
    end

    class OwnerOnlyCommand < BaseCommand

    end
  end
end
