require 'cinch'

module Plugins
  class Auth
    include Cinch::Plugin

    match /auth (.+)/

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
end
