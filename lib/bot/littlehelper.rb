require 'cinch'
require 'mediawiki-butt'
require 'require_all'
require 'twitter'
require 'weatheruby'
require 'pastee'
require 'cleverbot'
require 'sequel'
require_relative 'variables'
require_rel 'plugins'

module LittleHelper
  BUTT = MediaWiki::Butt.new(Variables::Constants::WIKI_URL)

  TWEETER = Twitter::REST::Client.new do |c|
    c.consumer_key = Variables::Constants::TWITTER_CONSUMER_KEY
    c.consumer_secret = Variables::Constants::TWITTER_CONSUMER_SECRET
    c.access_token = Variables::Constants::TWITTER_ACCESS_TOKEN
    c.access_token_secret = Variables::Constants::TWITTER_ACCESS_SECRET
  end

  WEATHER = Weatheruby.new(Variables::Constants::WUNDERGROUND_KEY, 'EN', true, true, true)

  PASTEE = Pastee.new(Variables::Constants::PASTEE_KEY)

  CLEVER = Cleverbot.new(Variables::Constants::CLEVER_USER, Variables::Constants::CLEVER_KEY)

  plugins = [
    Plugins::Commands::Authentication::SetPass,
    Plugins::Commands::Authentication::Login,
    Plugins::Commands::Authentication::Logout,
    Plugins::Commands::Quit,
    Plugins::Commands::Info::Help,
    Plugins::Commands::Info::Src,
    Plugins::Commands::Random,
    Plugins::Commands::Version,
    Plugins::Commands::Abbreviate,
    Plugins::Commands::CheckPage,
    Plugins::Commands::NewCategory,
    Plugins::Commands::AddQuote,
    Plugins::Commands::Upload,
    Plugins::Commands::GetContribs,
    Plugins::Commands::EightBall,
    Plugins::Commands::FlipCoin,
    Plugins::Commands::WikiStatistics,
    Plugins::Commands::NumberGame,
    Plugins::Commands::AddMod,
    Plugins::Commands::Tweet,
    Plugins::Commands::Weather,
    Plugins::Commands::BanInfo,
    Plugins::Commands::IssueLink,
    Plugins::Commands::MoveCategory,
    Plugins::Commands::MoveGeneral,
    Plugins::Commands::CategoryMembers,
    Plugins::Commands::ChangeCategory,
    Plugins::Commands::GetAbbreviation,
    Plugins::Commands::SubCategoryMembers,
    Plugins::Commands::NewVanilla,
    Plugins::Commands::CleverBot,
    Plugins::Commands::RefreshQuotes,
    Plugins::Commands::UrbanDict,
    Plugins::Commands::CheckMail,
    Plugins::Commands::Tell,
    Plugins::YouveGotMail,
    Plugins::Logger
  ]

  db = ENV.include?('DATABASE_URL')

  if db
    plugins << Plugins::Commands::CheckMail
    plugins << Plugins::Commands::Tell
    plugins << Plugins::YouveGotMail
  end

  unless Variables::Constants::DISABLED_PLUGINS.nil?
    Variables::Constants::DISABLED_PLUGINS.each do |p|
      constants = p.split('::')
      disabled = nil
      constants.each do |c|
        if disabled.nil?
          disabled = Object.const_get(c)
          next
        else
          disabled = disabled.const_get(c)
        end
      end
      plugins.delete(disabled)
    end
  end

  plugins.freeze

  DEV_MODE = ARGV.include?('-d')

  BOT = Cinch::Bot.new do
    # noinspection RubyResolve
    configure do |c|
      c.server = Variables::Constants::IRC_SERVER
      c.port = Variables::Constants::IRC_PORT
      c.channels = DEV_MODE ? Variables::Constants::IRC_DEV_CHANNELS : Variables::Constants::IRC_CHANNELS
      c.nicks = Variables::Constants::IRC_NICKNAMES
      c.user = Variables::Constants::IRC_USERNAME
      c.password = Variables::Constants::IRC_PASSWORD
      c.realname = Variables::Constants::IRC_REALNAME
      c.plugins.plugins = plugins
      c.plugins.prefix = DEV_MODE ? /^&/ : /^\$/

      CHANNELS = c.channels
    end
  end

  if db
    DB = Sequel.connect(ENV['DATABASE_URL'])
    unless DB.table_exists?(:messages)
      DB.create_table(:messages) do
        primary_key :id
        String :to
        String :from
        String :msg
      end
    end
  end

  module_function

  # Initializes the MediaWiki::Butt instance. Logs back in if necessary.
  # @return [MediaWiki::Butt].
  def init_wiki
    wiki_login unless BUTT.user_bot?

    BUTT
  end

  # Gets the Twitter instance.
  # @return [Twitter::Rest::Client]
  def init_twitter
    TWEETER
  end

  # Gets the Weatheruby instance.
  # @return [Weatheruby]
  def init_weather
    WEATHER
  end

  # Gets the Pastee instance.
  # @return [Pastee]
  def init_pastee
    PASTEE
  end

  # Logs into the wiki with MediaWiki::Butt.
  def wiki_login
    BUTT.login(Variables::Constants::WIKI_USERNAME, Variables::Constants::WIKI_PASSWORD)
  end

  # Starts the bot.
  def run
    BOT.start
  end

  def bot
    BOT
  end

  def clever
    CLEVER
  end

  # Quits the bot.
  # @param user [String] The user who is quitting the bot.
  def quit(user)
    BOT.quit("I will be avenged, #{user}!")
  end

  def message_table
    if db
      DB[:messages]
    end
  end
end
