require 'dotenv'

module Variables
  module Constants
    PWD = Dir.pwd

    Dotenv.load

    DISCORD_TOKEN = ENV['DISCORD_TOKEN'].freeze
    WIKI_URL = ENV['WIKI_URL'].freeze
    WIKI_USERNAME = ENV['WIKI_USERNAME'].freeze
    WIKI_PASSWORD = ENV['WIKI_PASSWORD'].freeze
    TWITTER_CONSUMER_KEY = ENV['TWITTER_CONSUMER_KEY'].freeze
    TWITTER_CONSUMER_SECRET = ENV['TWITTER_CONSUMER_SECRET'].freeze
    TWITTER_ACCESS_TOKEN = ENV['TWITTER_ACCESS_TOKEN'].freeze
    TWITTER_ACCESS_SECRET = ENV['TWITTER_ACCESS_SECRET'].freeze
    OPENWEATHERMAP_KEY = ENV['OPENWEATHERMAP_API_KEY'].freeze
    PASTEE_KEY = ENV['PASTEE_API_KEY'].freeze
    DICT_KEY = ENV['MERRIAMWEBSTER_API_KEY'].freeze
    DISABLED_PLUGINS = ENV['DISABLED_PLUGINS'].split(',')
    IGNORED_USERS = ENV['IGNORED_USERS'].split(',').freeze
    OWNER = ENV['OWNER'].freeze
    AUTHORIZED_ROLE_ID = ENV['AUTHORIZED_ROLE'].to_i

    MOTIVATE_PATH = "#{PWD}/lib/bot/info/motivate.txt".freeze
    FORTUNE_PATH = "#{PWD}/lib/bot/info/8ball.txt".freeze
  end

  module NonConstants
    @quotes = []

    module_function

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
