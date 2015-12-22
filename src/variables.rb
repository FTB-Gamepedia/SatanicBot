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
    PASTEE_KEY = CONFIG['pastee']['api_key']
    ISSUE_TRACKING = {}
    DISABLED_PLUGINS = CONFIG.key?('disabled') ? CONFIG['disabled'] : nil

    CONFIG['github'].each do |i|
      ISSUE_TRACKING[i['channel']] = i['repo']
    end

    people_path = "#{Dir.pwd}/src/info/valid_authnames.txt"
    VALID_PEOPLE = IO.read(people_path).split("\n")

    QUOTE_PATH = "#{Dir.pwd}/src/info/ircquotes.txt"
    MOTIVATE_PATH = "#{Dir.pwd}/src/info/motivate.txt"
  end

  module NonConstants
    extend self
    @authpass = Variables::Constants::CONFIG['irc']['default_auth_pass']
    @authedusers = []
    @commands = {}

    # Gets the command names and their docs.
    # @return [Hash] The commands.
    def get_commands
      @commands
    end

    # Adds a command to the hash.
    # @param name [String] The command name, basically whatever comes after $.
    # @param doc [String] The documentation of the command for $help.
    def add_command(name, doc)
      @commands[name] = doc
    end

    # Gets the authentication password set in the config or by $setpass..
    # @return [String] The password.
    def get_authentication_password
      @authpass
    end

    # Sets the authentication password to a new value. This does not update the
    #   actual config file.
    # @todo Actually update the config file for a permanent change.
    # @param new_password [String] The new password.
    def set_authentication_password(new_password)
      @authpass = new_password
    end

    # Gets all of the authenticated user's authnames.
    # @return [Array<String>] All of the authenticated user's NickServ usernames
    def get_authenticated_users
      @authedusers
    end

    # Authenticates the given user.
    # @param username [String] The user to authenticate.
    def authenticate_user(authname)
      @authedusers << authname
    end

    # De-authenticates a user.
    # @param username [String] The user to deauthenticate.
    def deauthenticate_user(authname)
      @authedusers.delete(authname)
    end
  end
end
