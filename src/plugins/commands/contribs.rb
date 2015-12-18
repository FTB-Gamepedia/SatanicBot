require 'cinch'
require 'string-utility'

module Plugins
  module Commands
    class GetContribs
      include Cinch::Plugin
      using StringUtility

      match(/contribs (.+)/i, method: :execute)
      match(/contribs$/i, method: :no_username)

      # Gets the amount of contributions and the registration date of the given
      #   user.
      # @param msg [Cinch::Message]
      # @param username [String] The username to check.
      # @param you [Boolean] Whether the username is also the user who performed
      #   the command.
      def execute(msg, username, you = false)
        butt = LittleHelper.init_wiki
        count = butt.get_contrib_count(username).to_s.separate
        date = butt.get_registration_time(username)
        month = date.strftime('%B')
        day = date.strftime('%e')
        year = date.strftime('%Y')

        message_start =
          if you
            'You have'
          elsif /[Ss]atanicBot/ =~ username
            'I have'
          elsif /[Tt]heSatanicSanta/ =~ username
            'The second hottest babe in the channel has'
          elsif /[Rr]etep998/ =~ username
            'The hottest babe in the channel has'
          elsif /[Pp]onyButt/ =~ username
            'Some stupid bitch has'
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
