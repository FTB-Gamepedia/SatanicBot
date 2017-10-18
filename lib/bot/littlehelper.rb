require 'cinch'
require 'mediawiki-butt'
require 'require_all'
require 'twitter'
require 'weatheruby'
require 'pastee'
require 'cleverbot'
require 'sequel'
require 'oxford_dictionary'
require 'time'
require_relative 'variables'
require_rel 'plugins'

module LittleHelper
  BUTT = MediaWiki::Butt.new(Variables::Constants::WIKI_URL, query_limit_default: 5000, assertion: :bot)

  TWEETER = Twitter::REST::Client.new do |c|
    c.consumer_key = Variables::Constants::TWITTER_CONSUMER_KEY
    c.consumer_secret = Variables::Constants::TWITTER_CONSUMER_SECRET
    c.access_token = Variables::Constants::TWITTER_ACCESS_TOKEN
    c.access_token_secret = Variables::Constants::TWITTER_ACCESS_SECRET
  end

  WEATHER = Weatheruby.new(Variables::Constants::WUNDERGROUND_KEY, 'EN', true, true)
  PASTEE = Pastee.new(Variables::Constants::PASTEE_KEY)
  CLEVER = Cleverbot.new(Variables::Constants::CLEVER_USER, Variables::Constants::CLEVER_KEY)
  DICTIONARY = OxfordDictionary.new(app_id: Variables::Constants::DICT_ID, app_key: Variables::Constants::DICT_KEY)

  plugins = [
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
    Plugins::Commands::Drama,
    Plugins::Commands::MojangStatus,
    Plugins::Commands::DeleteTiles,
    Plugins::Commands::ReadTweet,
    Plugins::Commands::Dictionary,
    Plugins::Commands::IsDisambiguation,
    Plugins::Commands::Editathon,
    Plugins::Commands::ModLinksSummary,
    Plugins::Logger
  ]

  HAS_DB = ENV.include?('DATABASE_URL')

  if HAS_DB
    plugins << Plugins::Commands::CheckMail
    plugins << Plugins::Commands::Tell
    plugins << Plugins::Commands::YouveGotMail
    plugins << Plugins::Commands::DeleteSentMessage
    plugins << Plugins::Commands::GetSentMessages
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

  if HAS_DB
    DB = Sequel.connect(ENV['DATABASE_URL'])
    unless DB.table_exists?(:messages)
      DB.create_table(:messages) do
        primary_key :id
        String :to
        String :from
        String :msg
        String :address
        String :at
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

  # Logs into the wiki with MediaWiki::Butt.
  def wiki_login
    BUTT.login(Variables::Constants::WIKI_USERNAME, Variables::Constants::WIKI_PASSWORD)
  end

  # Starts the bot.
  def run
    BOT.start
  end

  # Quits the bot.
  # @param user [String] The user who is quitting the bot.
  def quit(user)
    BOT.quit("I will be avenged, #{user}!")
  end

  # Returns the :messages table from the database.
  # @return [Sequel::Dataset] The message dataset.
  def message_table
    DB[:messages] if HAS_DB
  end
end

# TODO: Put monkeypatches in a nicer place
module MediaWiki
  class Butt
    # TODO: Implement better history stuff in MediaWiki-Butt
    # @param page [String] The page name to get the first edit timestamp for
    # @return [Time] The date and time for this page's first edit converted for UTC
    def first_edit_timestamp(page)
      params = {
        action: 'query',
        prop: 'revisions',
        titles: page,
        rvprop: 'timestamp',
        rvlimit: @query_limit_default
      }
      query(params) do |return_val, query|
        pageid = query['pages'].keys.find(MediaWiki::Constants::MISSING_PAGEID_PROC) { |id| id != '-1' }
        return [] if query['pages'][pageid].key?('missing')
        return_val.concat(query['pages'][pageid].fetch('revisions', []).collect { |h| Time.parse(h['timestamp']).utc })
      end.min
    end
  end
end

class Time
  def in_progress?(start_time, end_time)
    (start_time .. end_time).include?(clone.utc)
  end

  # Equivalent to calling #strftime('%FT%T'). It converts to UTC but does not modify this Time object.
  def xmlschema
    clone.utc.strftime('%FT%T')
  end

  # Parses a Time object from the xmlschema defined at #xmlschema. Time objects parsed with this and Time objects
  # converted to UTC using #utc are not equivalent, because this Time object's timezone is "+00:00" which is
  # functionally UTC but not UTC in name. There is no good alternative to this aside from depending on ActiveSuppport
  # for TimeWithZone, and this application already has Timerizer which modifies the Time object plenty.
  def self.xmlschema(str)
    times = str.match(/(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})T(?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2})/)
    Time.new(times[:year], times[:month], times[:day], times[:hour], times[:minute], times[:second], '+00:00')
  end
end
