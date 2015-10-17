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
    butt = MediaWiki::Butt.new 'http://ftb.gamepedia.com'
    butt.login('SatanicBot', Variables::Constants::PASSWORD)
    butt
  end

  def init_twitter
    twitter = Twitter::REST::Client.new do |c|
      c.consumer_key = GeneralUtils::Files.get_secure(2)
      c.consumer_secret = GeneralUtils::Files.get_secure(3)
      c.access_token = GeneralUtils::Files.get_secure(4)
      c.access_token_secret = GeneralUtils::Files.get_secure(5)
    end

    twitter
  end

  def init_weather
    weather = Weatheruby.new(GeneralUtils::Files.get_secure(6), 'EN', true,
                             true, true)
    weather
  end

  BOT = Cinch::Bot.new do
    configure do |c|
      c.server = 'irc.esper.net'
      c.port = 6667
      if ARGV[0] == '-d'
        c.channels = %w(#FTB-Wiki-Dev)
      else
        c.channels = %w(#FTB-Wiki #SatanicSanta #FTB-Wiki-Dev)
      end
      c.nicks = %w(LittleHelper SatanicBot SatanicButt)
      c.user = 'LittleHelper'
      c.password = Variables::Constants::PASSWORD
      c.realname = 'SatanicSanta\'s Big Fat Butt'
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
        Plugins::Commands::Weather
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
