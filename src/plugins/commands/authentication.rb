require 'cinch'
require_relative '../../variables'

module Plugins
  module Commands
    module Authentication
      class Login
        include Cinch::Plugin

        match(/login (.+)/i)

        @message = nil

        # Checks whether the log in is valid, sets the message to the proper
        #   value, and actually logs the user in.
        # @param authname [String] The user's authname (NickServ login)
        # @param pass [String] The password for LittleHelper that the user
        #   provided.
        # @return [void] when it is invalid. The request is invalid when:
        #   the user is not logged in, the user is already logged into
        #   LittleHelper, the password provided is not correct, or the user is
        #   not in the list of people who are allowed to login.
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

        # Attempts to log in.
        # @see check_valid
        def execute(msg, pass)
          check_valid(msg.user.authname, pass)
          msg.reply(@message)
        end
      end

      class Logout
        include Cinch::Plugin

        match(/logout/i)

        # Logs the user out.
        # @param msg [Cinch::Message]
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

        # Sets a new password for users to log in with.
        # @param msg [Cinch::Message]
        # @param new_pass [String] The new password.
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
