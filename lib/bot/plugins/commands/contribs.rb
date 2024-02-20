require 'string-utility'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class Contribs < BaseCommand
      include Plugins::Wiki
      using StringUtility

      def initialize
        super(:contribs, 'Provides the number of contributions and registration date for the user on the wiki.', 'contribs [user]')
        @attributes[:min_args] = 0
        @attributes[:max_args] = 1
      end

      # Gets the amount of contributions and the registration date of the given user.
      # @param event [Discordrb::Commands::CommandEvent]
      # @param args [Array<String>] The passed arguments.
      def execute(event, args)
        you = args.empty?
        username = you ? event.author.display_name : args[0]

        # TODO: Fix MediaWiki-Butt-Ruby#83
        begin
          count = wiki.get_contrib_count(username).to_s.separate
        rescue NoMethodError
          return "#{username} is not a user on the wiki."
        end
        
        date = wiki.get_registration_time(username)
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
        return "#{message_start} made #{message_contribs} to the wiki and registered on #{month} #{day}, #{year}"
      end
    end
  end
end
