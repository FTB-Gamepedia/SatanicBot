require 'cinch'
require 'timerizer'
require_relative 'base_command'

module Plugins
  module Commands
    class YouveGotMail < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      # Match anything but messages containing checkmail.
      match(/^(?!.*checkmail).*/i, use_prefix: false)

      # @param msg [Cinch::Message]
      def execute(msg)
        user = msg.user
        nick = user.nick
        nick_dc = nick.downcase
        auth = user.authname&.downcase
        user_times = Variables::NonConstants.get_mail_times
        return if user_times.key?(nick_dc) && Time.since(user_times[nick_dc]).minutes < 5
        return if user_times.key?(auth) && Time.since(user_times[auth]).minutes < 5
        table = LittleHelper.message_table
        count = table.where(to: [nick_dc, auth]).count
        if count > 0
          Variables::NonConstants.add_mail_time(auth ? auth : nick_dc, Time.now)
          msg.reply("#{nick}: You've got mail (#{count} unread)! Use the checkmail command to check your mail!")
        end
      end
    end
  end
end
