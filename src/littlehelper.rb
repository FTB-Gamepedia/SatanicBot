require 'cinch'
require 'mediawiki-butt'
require 'require_all'
require 'twitter'
require 'weatheruby'
require_relative 'variables'
require_rel 'plugins'

module LittleHelper
  extend self

  BUTT = MediaWiki::Butt.new(Variables::Constants::WIKI_URL)

  TWEETER = Twitter::REST::Client.new do |c|
    c.consumer_key = Variables::Constants::TWITTER_CONSUMER_KEY
    c.consumer_secret = Variables::Constants::TWITTER_CONSUMER_SECRET
    c.access_token = Variables::Constants::TWITTER_ACCESS_TOKEN
    c.access_token_secret = Variables::Constants::TWITTER_ACCESS_SECRET
  end

  WEATHER = Weatheruby.new(Variables::Constants::WUNDERGROUND_KEY, 'EN', true,
                           true, true)

  BOT = Cinch::Bot.new do
    configure do |c|
      c.server = Variables::Constants::IRC_SERVER
      c.port = Variables::Constants::IRC_PORT
      if ARGV[0] == '-d'
        c.channels = Variables::Constants::IRC_DEV_CHANNELS
      else
        c.channels = Variables::Constants::IRC_CHANNELS
      end
      c.nicks = Variables::Constants::IRC_NICKNAMES
      c.user = Variables::Constants::IRC_USERNAME
      c.password = Variables::Constants::IRC_PASSWORD
      c.realname = Variables::Constants::IRC_REALNAME
      c.plugins.plugins = [
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
        Plugins::Commands::MajorCategory,
        Plugins::Commands::MinorCategory,
        Plugins::Commands::AddQuote,
        Plugins::Commands::Upload,
        Plugins::Commands::AddNavbox,
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
        Plugins::Commands::Log
      ]
      c.plugins.prefix = /^\$/

      CHANNELS = c.channels
    end
  end

  def init_wiki
    wiki_login unless BUTT.user_bot?

    BUTT
  end

  def init_twitter
    TWEETER
  end

  def init_weather
    WEATHER
  end

  def wiki_login
    BUTT.login(Variables::Constants::WIKI_USERNAME,
               Variables::Constants::WIKI_PASSWORD)
  end

  def run
    log
    BOT.start
  end

  def log
    time = Time.now
    CHANNELS.each do |c|
      file_name = "#{Dir.pwd}/#{c}-#{time.year}-#{time.month}-#{time.day}.log"
      if File.file?(file_name)
        open(file_name, 'a') do |f|
          f.puts("\n\n## Logging start at #{time.hour}:#{time.min}:#{time.sec} " \
                 "#{time.zone}\n")
        end
      else
        File.new(file_name, 'a') do |f|
          f.puts("## Logging start at #{time.hour}:#{time.min}:#{time.sec} " \
                 "#{time.zone}\n")
        end
      end
    end
  end
end
