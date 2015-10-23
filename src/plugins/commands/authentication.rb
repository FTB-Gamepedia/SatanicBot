require 'cinch'
require_relative '../../variables'

module Plugins
  module Commands
    module Authentication
      class Login
        include Cinch::Plugin

        match(/login (.+)/i)

        def execute(msg, pass)
          authedusers = Variables::NonConstants.get_authenticated_users
          if Variables::Constants::VALID_PEOPLE.include?(msg.user.authname)
            if authedusers.include? msg.user.authname
              msg.reply('You are already logged in.')
            else
              if pass == Variables::NonConstants.get_authentication_password
                Variables::NonConstants.authenticate_user(msg.user.authname)
                msg.reply("You are now logged in as #{msg.user.authname}!")
              else
                msg.reply("Sorry, #{pass} is not the password.")
              end
            end
          else
            msg.reply('You are not on the list of valid users. If you think ' \
                      'this is an error, please contact Eli, and he may add ' \
                      'you to the list of valid authentication names.')
          end
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
