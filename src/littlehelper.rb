require 'cinch'
require 'mediawiki-butt'
require 'require_all'
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
        Plugins::Commands::Info::Command,
        Plugins::Commands::Random::Word,
        Plugins::Commands::Random::Sentence,
        Plugins::Commands::UpdateVersion,
        Plugins::Commands::Abbreviate,
        Plugins::Commands::CheckPage,
        Plugins::Commands::MajorCategory,
        Plugins::Commands::MinorCategory,
        Plugins::Commands::AddQuote,
        Plugins::Commands::Upload,
        Plugins::Commands::AddNavbox
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
