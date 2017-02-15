require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class GetSentMessages < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Privately sends the user all of the messages that they have sent that have not been read yet.',
          plugin_name: 'getsent')
      match(/getsent/i)

      def execute(msg)
        table = LittleHelper.message_table
        user = msg.user
        outgoing_messages = table.where(from: [user.nick, user.authname]).all
        if outgoing_messages.count < 1
          user.send('You have not sent any messages.')
          return
        end

        outgoing_messages.each do |message|
          user.send("Message ID #{message[:id]} to #{message[:to]}: #{message[:msg]}")
        end
      end
    end
  end
end
