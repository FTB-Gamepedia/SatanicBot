require 'cinch'

module Plugins
  module Authentication
    class Login
      include Cinch::Plugin

      match /login (.+)/i

      def execute(msg, pass)
        if $authedusers.include? msg.user.authname
          msg.reply('You are already logged in.')
        else
          if pass == $password
            $authedusers.push(msg.user.authname)
            msg.reply("You are now logged in as #{msg.user.authname}!")
          else
            msg.reply("Sorry, #{pass} is not the password.")
          end
        end
      end
    end

    class Logout
      include Cinch::Plugin

      match /logout/i

      def execute(msg)
        if $authedusers.include? msg.user.authname
          $authedusers.delete(msg.user.authname)
          msg.reply('You have been logged out.')
        else
          msg.reply('You are not logged in to begin with.')
        end
      end
    end

    class SetPass
      include Cinch::Plugin

      match /setpass (.+)/i

      def execute(msg, new_pass)
        if msg.user.authname == 'SatanicSanta'
          $password = new_pass
          msg.reply("Password set to #{new_pass}.")
        else
          msg.reply('Sorry, you do not have permission to do this action.')
        end
      end
    end
  end
end
