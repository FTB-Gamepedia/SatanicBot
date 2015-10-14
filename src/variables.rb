require_relative 'generalutils'

module Variables
  module Constants
    WIKIUSER = 'SatanicBot'
    PASSWORD = GeneralUtils::Files.get_secure(0)
    TWITUSER = 'LittleHelperBot'
    COMMANDS = {
      'login' => 'Logs the user in, allowing for op-only commands. ' \
                '1 arg: $login <password>',
      'logout' => 'Logs the user out. No args.',
      'setpass' => 'Sets the auth password. Santa-only command. ' \
                   '1 arg: $setpass <newpassword>',
      'quit' => 'Murders me. Santa-only command. No args.',
      'help' => 'Gets basic usage information on the bot.',
      'src' => 'Outputs my creator\'s name and the repository for me.',
      'command' => 'Gets info on a command. 1 arg: $command <commandname>',
      'word' => 'Outputs a random word. No args.',
      'sentence' => 'Outputs a random sentence. No args.',
      'updatevers' => 'Updates a mod version on the wiki. Op-only command. ' \
                      '2 args: $updatevers <mod page> <mod version>. Args ' \
                      'must be wrapped in <> for this command.',
      'abbrv' => 'Abbreivates a mod for the tilesheet extension. ' \
                 'An op-only command. 2 args: $abbrv <abbreviation> <mod_name>',
      'checkpage' => 'Checks if the page exists. 1 arg: $checkpage <page>',
      'newminorcat' => 'Creates a new minor mod category. 1 arg: ' \
                        '$newminorcat <name>',
      'newmodcat' => 'Creates a standard mod category. 1 arg: $newmodcat ' \
                      '<name>'
    }
  end

  module NonConstants
    extend self
    @@authpass = GeneralUtils::Files.get_secure(1)
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
