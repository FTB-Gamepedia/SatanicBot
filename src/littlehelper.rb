require 'cinch'
require 'mediawiki-butt'
require 'require_all'
require 'twitter'
require 'weatheruby'
require_relative 'generalutils'
require_relative 'variables'
require_rel 'plugins'

module LittleHelper
  extend self

  def init_wiki
    url = Variables::Constants::WIKI_URL
    username = Variables::Constants::WIKI_USERNAME
    password = Variables::Constants::WIKI_PASSWORD
    butt = MediaWiki::Butt.new(url)
    butt.login(username, password)
    butt
  end

  def init_twitter
    consumer_key = Variables::Constants::TWITTER_CONSUMER_KEY
    consumer_secret = Variables::Constants::TWITTER_CONSUMER_SECRET
    access_token = Variables::Constants::TWITTER_ACCESS_TOKEN
    access_secret = Variables::Constants::TWITTER_ACCESS_SECRET
    twitter = Twitter::REST::Client.new do |c|
      c.consumer_key = consumer_key
      c.consumer_secret = consumer_secret
      c.access_token = access_token
      c.access_token_secret = access_secret
    end

    twitter
  end

  def init_weather
    api_key = Variables::Constants::WUNDERGROUND_KEY
    weather = Weatheruby.new(api_key, 'EN', true, true, true)
    weather
  end

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
        Plugins::Commands::UpdateVersion,
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
        Plugins::Commands::BanInfo
      ]
      c.plugins.prefix = /^\$/
    end

    on :ban do |msg, ban|
      msg.reply("#{ban.by} just knocked the fuck out of #{ban.mask}")
    end

    on :unban do |msg, ban|
      msg.reply('And here I was thinking we were going to have some ' \
                "peace and quiet, but now #{ban.mask} is unbanned by #{ban.by}")
    end
  end

  def run
    BOT.start
  end
end
