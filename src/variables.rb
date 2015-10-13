module Variables
  module Constants
    WIKIUSER = GeneralUtils::Files.get_secure(0)
    PASSWORD = GeneralUtils::Files.get_secure(1)
    TWITUSER = GeneralUtils::Files.get_secure(2)
    COMMANDS = {
      'login' => 'Logs the user in, allowing for op-only commands. ' \
                '1 arg: $auth <password>',
      'logout' => 'Logs the user out. No args.',
      'setpass' => 'Sets the auth password. Santa-only command. ' \
                   '1 arg: $setpass <newpassword>',
      'quit' => 'Murders me. Santa-only command. No args.',
      'help' => 'Gets basic usage information on the bot.',
      'src' => 'Outputs my creator\'s name and the repository for me.',
      'command' => 'Gets information on a command. 1 arg: $command <commandname>',
      'word' => 'Outputs a random word. No args.',
      'sentence' => 'Outputs a random sentence. No args.'
    }
  end

  module NonConstants
    extend self
    @@authpass = GeneralUtils::Files.get_secure(3)
    @@authedusers = []

    def get_authentication_password
      @@authpass
    end

    def set_authentication_password(new_password)
      @@authpass = new_password
    end

    def get_authenticated_users
      @@authedusers
    end

    def authenticate_user(authname)
      @@authedusers.push(authname)
    end

    def deauthenticate_user(authname)
      @@authedusers.delete(authname)
    end
  end
end
