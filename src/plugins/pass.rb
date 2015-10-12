require 'cinch'

module Plugins
  class Pass
    include Cinch::Plugin

    match /pass (.+)/i

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
