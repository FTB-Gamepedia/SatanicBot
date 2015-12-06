require 'yaml'

module Variables
  module Constants
    CONFIG = YAML.load_file("#{Dir.pwd}/config.yml")

    IRC_USERNAME = CONFIG['irc']['username']
    IRC_PASSWORD = CONFIG['irc']['password']
    IRC_REALNAME = CONFIG['irc']['realname']
    IRC_NICKNAMES = CONFIG['irc']['nicknames']
    IRC_SERVER = CONFIG['irc']['server']
    IRC_PORT = CONFIG['irc']['port']
    IRC_CHANNELS = CONFIG['irc']['channels']
    IRC_DEV_CHANNELS = CONFIG['irc']['dev_channels']
    WIKI_URL = CONFIG['wiki']['url']
    WIKI_USERNAME = CONFIG['wiki']['username']
    WIKI_PASSWORD = CONFIG['wiki']['password']
    TWITTER_CONSUMER_KEY = CONFIG['twitter']['consumer_key']
    TWITTER_CONSUMER_SECRET = CONFIG['twitter']['consumer_secret']
    TWITTER_ACCESS_TOKEN = CONFIG['twitter']['access_token']
    TWITTER_ACCESS_SECRET = CONFIG['twitter']['access_secret']
    WUNDERGROUND_KEY = CONFIG['wunderground']['api_key']
    ISSUE_TRACKING = {}
    CONFIG['github'].each do |i|
      ISSUE_TRACKING[i['channel']] = i['repo']
    end

    people_path = "#{Dir.pwd}/src/info/valid_authnames.txt"
    VALID_PEOPLE = IO.read(people_path).split("\n")

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
                      '2 args: $updatevers <mod page> | <mod version>. Args ' \
                      'must be separated with a pipe in this command.',
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
                  '$addnav <navbox> <page>. Args must be separated by a pipe ' \
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
                'a game by doing $game quit.',
      'motivate' => 'Motivates you or the user you provide in the first arg. ' \
                    'If the user in the first arg is not in the channel, I ' \
                    'will motivate you instead <3.',
      'addmod' => 'Adds a mod to the list of mods on the main page. ' \
                  'Op-only. 1 arg: $addmod <mod name>',
      'addminor' => 'Adds a mod to the list of minor mods on the main page. ' \
                    'Op-only. 1 arg: $addminor <mod name>',
      'tweet' => 'Tweets the first arg on the LittleHelperBot Twitter account.',
      'weather' => 'Provides weather information for the given place. 1 arg: ' \
                   '$weather <place>',
      'forecast' => 'Provides forecast information for the next 3 days. 1 ' \
                    'arg: $forecast <place>',
      'banned' => 'Gets whether or not a user has been banned on MC servers. ' \
                  '1 arg: $banned <username>.',
      'checkvers' => 'Gets the current version on the page. 1 arg: ' \
                     '$checkvers <page name>',
      'movecat' => 'Moves one category to another, and edits all its members.' \
                   ' The parameters must be separated with a ->. ' \
                   '$movecat <old_cat> -> <new_cat>',
      'safemove' => 'Moves a page to a new page, with no redirect, including ' \
                    'subpages such as talk pages. Will also update all ' \
                    'pages that link to it. $safemove <old_page> -> <new_page>'
    }
  end

  module NonConstants
    extend self
    @authpass = Variables::Constants::CONFIG['irc']['default_auth_pass']
    @authedusers = []

    def get_authentication_password
      @authpass
    end

    def set_authentication_password(new_password)
      @authpass = new_password
    end

    def get_authenticated_users
      @authedusers
    end

    def authenticate_user(authname)
      @authedusers << authname
    end

    def deauthenticate_user(authname)
      @authedusers.delete(authname)
    end
  end
end
