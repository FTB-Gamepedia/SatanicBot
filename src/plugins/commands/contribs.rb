require 'cinch'

module Plugins
  module Commands
    class GetContribs
      include Cinch::Plugin

      match(/contribs (.+)/i, method: :execute)
      match(/contribs$/i, method: :no_username)

      def execute(msg, username, you = false)
        butt = LittleHelper.init_wiki
        count = butt.get_contrib_count(username)
        date = butt.get_registration_time(username)

        message_start =
          if you
            'You have'
          elsif /[Ss]atanicBot/ =~ username
            'I have'
          elsif /[Tt]heSatanicSanta/ =~ username
            'The seccond hottest babe in the channel has'
          elsif /[Rr]etep998/ =~ username
            'The hottest babe in the channel has'
          elsif /[Pp]onyButt/ =~ username
            'Some stupid bitch has'
          else
            "#{username} has"
          end
        message_contribs =
          if count == '1'
            '1 contribution'
          else
            "#{count} contributions"
          end
        message = "#{message_start} made #{message_contribs} to the wiki and " \
                  "registered on #{date}"
        msg.reply(message)
      end

      def no_username(msg)
        execute(msg, msg.user.nick, true)
      end
    end
  end
end
