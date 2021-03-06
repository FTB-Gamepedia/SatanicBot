require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class CheckMail < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Checks the user mail and sends it to them publicly. No arguments.', plugin_name: 'checkmail')
      match(/checkmail/)

      # Cinch formatting color symbols.
      COLORS = [
        :aqua,
        :black,
        :blue,
        :brown,
        :green,
        :grey,
        :lime,
        :orange,
        :pink,
        :purple,
        :red,
        :royal,
        :silver,
        :teal,
        :white,
        :yellow
      ]

      # TODO: Move all Time formats that are like this (eg. editathon command) into a centralized location.
      FORMAT = '%B %e %Y %H:%M:%S UTC'.freeze

      # @param msg [Cinch::Message]
      def execute(msg)
        table = LittleHelper.message_table
        user = msg.user
        if !user.authed? || user.authname.empty?
          msg.reply('You must be authenticated to use the checkmail command.')
          return
        end
        their_messages = table.where(to: [user.authname.downcase]).all
        total_count = their_messages.count
        if total_count < 1
          msg.reply('You have no unread messages.')
          return
        end

        # Remove the :id key because we do not use it, and it makes every entry unique.
        their_messages.map { |hash| hash.delete(:id) }
        unique_messages = their_messages.uniq
        color = unique_messages.count > 10

        msg.reply("You have #{total_count} unread messages. Reading...")
        unique_messages.each do |hash|
          # Use msg.user.nick instead of hash[:to] because it is lowercase, but nick has proper formatting/casing.
          count = their_messages.count(hash)
          reply = "#{user.nick}: #{hash[:from]} says \"#{hash[:msg]}\""
          reply << " from #{hash[:address]} at #{Time.xmlschema(hash[:at]).strftime(FORMAT)}"
          reply << " #{count} times" if count > 1
          msg.reply(color ? Format(COLORS.sample, reply) : reply)
        end
        deleted = table.where(to: user.authname.downcase).delete
        msg.reply("Finished reading unread messages. Deleted #{deleted} message#{deleted == 1 ? '' : 's'}.")
      end
    end
  end
end
