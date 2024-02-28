require 'discordrb'
require 'require_all'
require 'time'
require 'pastee'
require 'x'
require_relative 'extended_butt'
require_relative 'variables'
# require_rel 'plugins/commands'
require_rel 'plugins/message_event_handlers'
require_relative 'plugins/commands/8ball'
require_relative 'plugins/commands/flip_coin'
require_relative 'plugins/commands/src'
require_relative 'plugins/commands/random'
require_relative 'plugins/commands/get_abbrv'
require_relative 'plugins/commands/contribs'
require_relative 'plugins/commands/mod_links_summary'
require_relative 'plugins/commands/is_disambiguation'
require_relative 'plugins/commands/check_page'
require_relative 'plugins/commands/kill'
require_relative 'plugins/commands/abbreviate'
require_relative 'plugins/commands/new_vanilla'
require_relative 'plugins/commands/refresh_quotes'
require_relative 'plugins/commands/add_quote'
require_relative 'plugins/commands/tweet'
require_relative 'plugins/commands/upload'

module LittleHelper
  BUTT = ExtendedButt.new(Variables::Constants::WIKI_URL, query_limit_default: 5000, assertion: :bot)

  X_CLIENT = X::Client.new(
    api_key: Variables::Constants::X_API_KEY, 
    api_key_secret: Variables::Constants::X_API_SECRET, 
    access_token: Variables::Constants::X_ACCESS_TOKEN,
    access_token_secret: Variables::Constants::X_ACCESS_SECRET)

  # WEATHER = OpenWeatherMap::API.new(Variables::Constants::OPENWEATHERMAP_KEY, 'en', 'metric')
  PASTEE = Pastee.new(Variables::Constants::PASTEE_KEY)
  # DICTIONARY = MWDictionaryAPI::Client.new(Variables::Constants::DICT_KEY, api_type: 'collegiate')

  commands = [
    Plugins::Commands::Abbreviate.new,
    Plugins::Commands::AddQuote.new,
    Plugins::Commands::CheckPage.new,
    Plugins::Commands::Contribs.new,
    Plugins::Commands::EightBall.new,
    Plugins::Commands::FlipCoin.new,
    Plugins::Commands::GetAbbreviation.new,
    Plugins::Commands::IsDisambiguation.new,
    Plugins::Commands::Kill.new,
    Plugins::Commands::ModLinksSummary.new,
    Plugins::Commands::Random::RandomWord.new,
    Plugins::Commands::Random::RandomSentence.new,
    Plugins::Commands::Random::RandomQuote.new,
    Plugins::Commands::Random::RandomNumber.new,
    Plugins::Commands::Random::Motivate.new,
    Plugins::Commands::RefreshQuotes.new,
    Plugins::Commands::Src.new,
    Plugins::Commands::Tweet.new,
    Plugins::Commands::Upload.new,
    Plugins::Commands::NewVanilla.new
  ].freeze

  message_event_handlers = [
    Plugins::MessageEventHandlers::IssueLink.new,
    Plugins::MessageEventHandlers::UrbanDict.new
  ].freeze

  DEV_MODE = ARGV.include?('-d')

  BOT = Discordrb::Commands::CommandBot.new(token: Variables::Constants::DISCORD_TOKEN, prefix: DEV_MODE ? '&' : '$', intents: [ Discordrb::INTENTS[:server_messages] ])
  commands.each do |command|
    BOT.command(command.name, command.attributes) do |event, *args|
      command.execute(event, args) if command.can_execute?(event)
    end
  end
  message_event_handlers.each do |meh|
    BOT.message(meh.attributes) do |event|
      event.respond(meh.execute(event)) if meh.can_execute?(event)
    end
  end

  at_exit { BOT.stop }

  module_function

  # Starts the bot.
  def run
    BOT.run
  end

  # Returns the :messages table from the database.
  # @return [Sequel::Dataset] The message dataset.
  def message_table
    DB[:messages] if HAS_DB
  end
end

# TODO: Put monkeypatches in a nicer place
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
