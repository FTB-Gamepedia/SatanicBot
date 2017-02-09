require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    module Authentication
      class Login < BaseCommand
        include Cinch::Plugin
        ignore_ignored_users

        match(/login (.+)/i)

        @message = nil

        DOC = 'Logs the user in, allowing for op-only commands. 1 arg: $login <password>'.freeze
        Variables::NonConstants.add_command('login', DOC)

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

          nickserv = 'You must be authenticated with Nickserv.'.freeze
          already = 'You are already logged in.'.freeze
          incorrect = "Sorry, #{pass} is not the password."
          not_valid = 'You are not on the list of valid users. If you think ' \
                      'this is an error, please contact Eli, and he may add ' \
                      'you to the list of valid authentication names.'.freeze
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

          unless people.map(&:downcase).include? authname.downcase
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

        DOC = 'Logs the user out. No args.'.freeze
        Variables::NonConstants.add_command('logout', DOC)

        # Logs the user out.
        # @param msg [Cinch::Message]
        def execute(msg)
          return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          authedusers = Variables::NonConstants.get_authenticated_users
          if authedusers.include? msg.user.authname
            Variables::NonConstants.deauthenticate_user(msg.user.authname)
            msg.reply('You have been logged out.'.freeze)
          else
            msg.reply('You are not logged in to begin with.'.freeze)
          end
        end
      end

      class SetPass
        include Cinch::Plugin

        match(/setpass (.+)/i)

        DOC = 'Sets the login password. Owner-only command. 1 arg: $setpass <new password>'.freeze
        Variables::NonConstants.add_command('setpass', DOC)

        # Sets a new password for users to log in with.
        # @param msg [Cinch::Message]
        # @param new_pass [String] The new password.
        def execute(msg, new_pass)
          return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
          if msg.user.authname == Variables::Constants::OWNER
            if new_pass == Variables::NonConstants.get_authentication_password
              msg.reply('That is already the password.'.freeze)
            else
              Variables::NonConstants.set_authentication_password(new_pass)
              msg.reply("Password set to #{new_pass}.")
            end
          else
            msg.reply(Variables::Constants::OWNER_ONLY)
          end
        end
      end
    end
  end
end
