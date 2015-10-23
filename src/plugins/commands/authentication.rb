require 'cinch'
require_relative '../../variables'

module Plugins
  module Commands
    module Authentication
      class Login
        include Cinch::Plugin

        match(/login (.+)/i)

        @message = nil

        def check_valid(authname, pass)
          authedusers = Variables::NonConstants.get_authenticated_users
          true_pass = Variables::NonConstants.get_authentication_password
          people = Variables::Constants::VALID_PEOPLE

          nickserv = 'You must be authenticated with Nickserv.'
          already = 'You are already logged in.'
          incorrect = "Sorry, #{pass} is not the password."
          not_valid = 'You are not on the list of valid users. If you think ' \
                      'this is an error, please contact Eli, and he may add ' \
                      'you to the list of valid authentication names.'
          success = "You are now logged in as #{authname}"
          valid = true

          if authname.nil?
            @message = nickserv
            valid = false
          end

          if authedusers.include? authname
            @message = already
            valid = false
          end

          if pass != true_pass
            @message = incorrect
            valid = false
          end

          unless people.include? authname
            @message = not_valid
            valid = false
          end

          return unless valid

          @message = success
          Variables::NonConstants.authenticate_user(authname)
        end

        def execute(msg, pass)
          check_valid(msg.user.authname, pass)
          msg.reply(@message)
        end
      end

      class Logout
        include Cinch::Plugin

        match(/logout/i)

        def execute(msg)
          authedusers = Variables::NonConstants.get_authenticated_users
          if authedusers.include? msg.user.authname
            Variables::NonConstants.deauthenticate_user(msg.user.authname)
            msg.reply('You have been logged out.')
          else
            msg.reply('You are not logged in to begin with.')
          end
        end
      end

      class SetPass
        include Cinch::Plugin

        match(/setpass (.+)/i)

        def execute(msg, new_pass)
          if msg.user.authname == 'SatanicSanta'
            if new_pass == Variables::NonConstants.get_authentication_password
              msg.reply('That is already the password.')
            else
              Variables::NonConstants.set_authentication_password(new_pass)
              msg.reply("Password set to #{new_pass}.")
            end
          else
            msg.reply('Sorry, you do not have permission to do this action.')
          end
        end
      end
    end
  end
end
