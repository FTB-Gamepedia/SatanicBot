require 'dotenv'

module Variables
  module Constants
    PWD = Dir.pwd

    Dotenv.load

    IRC_USERNAME = ENV['IRC_USERNAME'].freeze
    IRC_PASSWORD = ENV['IRC_PASSWORD'].freeze
    IRC_REALNAME = ENV['IRC_REALNAME'].freeze
    IRC_NICKNAMES = ENV['IRC_NICKNAMES'].split(',').freeze
    IRC_SERVER = ENV['IRC_SERVER'].freeze
    IRC_PORT = ENV['IRC_PORT'].to_i.freeze
    IRC_CHANNELS = ENV['IRC_CHANNELS'].split(',').freeze
    IRC_DEV_CHANNELS = ENV['IRC_DEV_CHANNELS'].split(',').freeze
    WIKI_URL = ENV['WIKI_URL'].freeze
    WIKI_USERNAME = ENV['WIKI_USERNAME'].freeze
    WIKI_PASSWORD = ENV['WIKI_PASSWORD'].freeze
    TWITTER_CONSUMER_KEY = ENV['TWITTER_CONSUMER_KEY'].freeze
    TWITTER_CONSUMER_SECRET = ENV['TWITTER_CONSUMER_SECRET'].freeze
    TWITTER_ACCESS_TOKEN = ENV['TWITTER_ACCESS_TOKEN'].freeze
    TWITTER_ACCESS_SECRET = ENV['TWITTER_ACCESS_SECRET'].freeze
    OPENWEATHERMAP_KEY = ENV['OPENWEATHERMAP_API_KEY'].freeze
    PASTEE_KEY = ENV['PASTEE_API_KEY'].freeze
    CLEVER_USER = ENV['CLEVERBOT_API_USER'].freeze
    CLEVER_KEY = ENV['CLEVERBOT_API_KEY'].freeze
    DICT_KEY = ENV['MERRIAMWEBSTER_API_KEY'].freeze
    DISABLED_PLUGINS = ENV['DISABLED_PLUGINS'].split(',')
    IGNORED_USERS = ENV['IGNORED_USERS'].split(',') + IRC_NICKNAMES
    IGNORED_USERS.freeze
    OWNER = ENV['OWNER']

    # rubocop:disable Style/MutableConstant
    ISSUE_TRACKING = {}
    githubs = ENV['GITHUB'].split('|')
    githubs.each do |i|
      ary = i.split(',')
      ISSUE_TRACKING[ary[0]] = ary[1]
    end
    # rubocop:enable Style/MutableConstant

    ISSUE_TRACKING.freeze

    VALID_PEOPLE = ENV['VALID_AUTHNAMES'].split(',').freeze

    MOTIVATE_PATH = "#{PWD}/lib/bot/info/motivate.txt".freeze
    FORTUNE_PATH = "#{PWD}/lib/bot/info/8ball.txt".freeze

    NOT_VERIFIED = 'You are not verified to use this command. If you think this is a mistake, talk to the operator'.freeze
    OWNER_ONLY = 'This command is for the owner only.'.freeze
  end

  module NonConstants
    @quotes = []
    @youve_got_mail_times = {}

    module_function

    def get_mail_times
      @youve_got_mail_times
    end

    def add_mail_time(user, time)
      @youve_got_mail_times[user] = time
    end

    # Gets the current quote array, or refreshes it.
    # @param refresh [Boolean] Whether to refresh the array. Will automatically refresh if it has not been initialized.
    # @return [Array<String>] The quotes array.
    def get_quotes(refresh = false)
      if refresh || @quotes.empty?
        butt = LittleHelper::BUTT
        quotes = butt.get_text('User:SatanicBot/NotGoodEnoughForENV/Quotes').split("\n")
        quotes.delete('<nowiki>')
        quotes.delete('</nowiki>')
        @quotes = quotes
      end
      @quotes
    end

    # Adds a quote to the quote array. Does NOT add it to the actual quote list on the wiki.
    # @param quote [String] The quote.
    # @return [void]
    def append_quote(quote)
      @quotes << quote
    end
  end
end
