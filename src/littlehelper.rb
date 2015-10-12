require 'cinch'
require_relative 'generalutils'

require_relative 'plugins/commands/authentication'
require_relative 'plugins/commands/quit'

$wikiuser = GeneralUtils::Files.get_secure(0)
$password = GeneralUtils::Files.get_secure(1)
$twituser = GeneralUtils::Files.get_secure(2)
$authpass = GeneralUtils::Files.get_secure(3)

$authedusers = []

def init_wiki
   $butt = MediaWiki::Butt.new 'http://ftb.gamepedia.com'
   $butt.login('SatanicBot', $password)
end


bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.esper.net'
    c.port = 6667
    c.channels = ['#FTB-Wiki-Dev']
    # c.channels = ['#FTB-Wiki', '#SatanicSanta', '#FTB-Wiki-Dev']
    c.nicks = ['LittleHelper', 'SatanicBot', 'SatanicButt']
    c.user = 'LittleHelper'
    c.password = $password
    c.realname = 'SatanicSanta\'s Big Fat Butt'
    c.plugins.plugins = [
      Plugins::Commands::Authentication::SetPass,
      Plugins::Commands::Authentication::Login,
      Plugins::Commands::Authentication::Logout,
      Plugins::Commands::Quit
    ]
    c.plugins.prefix = /^\$/
    c
  end
end

bot.start
