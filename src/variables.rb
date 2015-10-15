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
      'help' => 'Gets basic usage information on the bot. 1 optional arg: ' \
                '$help <command> to get info on a command.',
      'src' => 'Outputs my creator\'s name and the repository for me.',
      'randword' => 'Outputs a random word. No args.',
      'randsentence' => 'Outputs a random sentence. No args.',
      'randquote' => 'Gives a random quote from the IRC channel. No args',
      'randnum' => 'Generates a random number. 1 optional arg, if not ' \
                   'provided I will assume 0-100: <max num>',
      'updatevers' => 'Updates a mod version on the wiki. Op-only command. ' \
                      '2 args: $updatevers <mod page> <mod version>. Args ' \
                      'must be wrapped in <> for this command.',
      'abbrv' => 'Abbreivates a mod for the tilesheet extension. ' \
                 'An op-only command. 2 args: $abbrv <abbreviation> <mod_name>',
      'checkpage' => 'Checks if the page exists. 1 arg: $checkpage <page>',
      'newminorcat' => 'Creates a new minor mod category. 1 arg: ' \
                        '$newminorcat <name>',
      'newmodcat' => 'Creates a standard mod category. 1 arg: $newmodcat ' \
                      '<name>',
      'addquote' => 'Adds a string to the quote list. Op-only. 1 arg: ' \
                      '$addquote <quote>',
      'upload' => 'Uploads a web file to the wiki. Op-only. 2 args: $upload ' \
                  '<url> <filename>',
      'addnav' => 'Adds the navbox to the template list. Op-only. 2 args: ' \
                  '$addnav <navbox> <page>. Args must be wrapped in <> ' \
                  'for this command.',
      'contribs' => 'Provides the user\'s number of contribs to the wiki and ' \
                    'registration date. 1 optional arg: <username>. If no ' \
                    'arg is given, I will use the user\'s IRC nickname.',
      '8ball' => 'Determines your fortune. No args',
      'flip' => 'Heads or tails! No args',
      'stats' => 'Gives wiki stats. 1 optional arg: <pages or articles or ' \
                 'edits or images or users or activeusers or admins>.',
      'game' => 'Number guessing game. Initialize with $game start. Then ' \
                'guess numbers by doing $game guess <number>. You can exit ' \
                'a game by doing $game quit.'
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
