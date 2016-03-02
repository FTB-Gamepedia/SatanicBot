require 'cinch'
require 'string-utility'

module Plugins
  module Commands
    class GetContribs
      include Cinch::Plugin
      using StringUtility

      match(/contribs (.+)/i, method: :execute)
      match(/contribs$/i, method: :no_username)

      DOC = "Provides the user's number of contributions and their registration date on the wiki. " \
            "1 optional arg: $contribs <username> If no arg is given, it will default to the user's " \
            'IRC nickname.'.freeze
      Variables::NonConstants.add_command('contribs', DOC)

      # Gets the amount of contributions and the registration date of the given
      #   user.
      # @param msg [Cinch::Message]
      # @param username [String] The username to check.
      # @param you [Boolean] Whether the username is also the user who performed
      #   the command.
      def execute(msg, username, you = false)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        butt = LittleHelper.init_wiki
        count = butt.get_contrib_count(username).to_s.separate
        date = butt.get_registration_time(username)
        month = date.strftime('%B').strip
        day = date.strftime('%e').strip
        year = date.strftime('%Y').strip

        message_start =
          if you
            'You have'.freeze
          elsif /[Ss]atanicBot/ =~ username
            'I have'.freeze
          elsif /[Tt]heSatanicSanta/ =~ username
            'The second hottest babe in the channel has'.freeze
          elsif /[Rr]etep998/ =~ username
            'The hottest babe in the channel has'.freeze
          elsif /[Pp]onyButt/ =~ username
            'Some stupid bitch has'.freeze
          else
            "#{username} has"
          end

        message_contribs = count == '1' ? '1 contribution' : "#{count} contributions"
        message = "#{message_start} made #{message_contribs} to the wiki and " \
                  "registered on #{month} #{day}, #{year}"
        msg.reply(message)
      end

      # Gets the amount of contributions and the registration date of the user
      #   who performed the command, by their IRC nickname.
      # @see execute
      # @param msg [Cinch::Message]
      def no_username(msg)
        execute(msg, msg.user.nick, true)
      end
    end
  end
end
