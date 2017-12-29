require 'cinch'
require 'string-utility'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class GetContribs < BaseCommand
      include Cinch::Plugin
      include Plugins::Wiki
      using StringUtility
      ignore_ignored_users

      set(help: 'Provides the number of contributions and the registration date of the user on the wiki. ' \
                '1 option arg: $contribs [username]. If no arg is given, it will use the nickname of the user.',
          plugin_name: 'contribs')
      match(/contribs (.+)/i, method: :execute)
      match(/contribs$/i, method: :no_username)

      # Gets the amount of contributions and the registration date of the given user.
      # @param msg [Cinch::Message]
      # @param username [String] The username to check.
      # @param you [Boolean] Whether the username is also the user who performed the command.
      def execute(msg, username, you = false)
        butt = wiki
        count = butt.get_contrib_count(username).to_s.separate
        unless count
          msg.reply("#{username} is not a user on the wiki.")
          return
        end
        date = butt.get_registration_time(username)
        month = date.strftime('%B').strip
        day = date.strftime('%e').strip
        year = date.strftime('%Y').strip

        message_start =
          if you
            'You have'.freeze
          elsif username.casecmp('SatanicBot').zero?
            'I have'.freeze
          elsif username.casecmp('TheSatanicSanta').zero?
            'The second hottest babe in the channel has'.freeze
          elsif username.casecmp('Retep998').zero?
            'The hottest babe in the channel has'.freeze
          elsif username.casecmp('PonyButt').zero?
            'Some stupid bitch has'.freeze
          else
            "#{username} has"
          end

        message_contribs = count == '1' ? '1 contribution' : "#{count} contributions"
        message = "#{message_start} made #{message_contribs} to the wiki and registered on #{month} #{day}, #{year}"
        msg.reply(message)
      end

      # Gets the amount of contributions and the registration date of the user who performed the command.
      # @see execute
      # @param msg [Cinch::Message]
      def no_username(msg)
        execute(msg, msg.user.nick, true)
      end
    end
  end
end
