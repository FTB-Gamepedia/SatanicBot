require 'cinch'
require_relative 'generalutils'

require_relative 'plugins/commands/authentication'
require_relative 'plugins/commands/quit'
require_relative 'plugins/commands/random'
require_relative 'plugins/commands/info'

$wikiuser = GeneralUtils::Files.get_secure(0)
$password = GeneralUtils::Files.get_secure(1)
$twituser = GeneralUtils::Files.get_secure(2)
$authpass = GeneralUtils::Files.get_secure(3)

$authedusers = []

$commands = {
  'login' => 'Logs the user in, allowing for op-only commands. ' \
            '1 arg: $auth <password>',
  'logout' => 'Logs the user out. No args.',
  'setpass' => 'Sets the auth password. Santa-only command. ' \
              '1 arg: $setpass <newpassword>',
  'quit' => 'Murders me. Santa-only command. No args.',
  'help' => 'Gets basic usage information on the bot.',
  'src' => 'Outputs my creator\'s name and the repository for me.',
  'command' => 'Gets information on a command. 1 arg: $command <commandname>',
  'word' => 'Outputs a random word. No args.',
  'sentence' => 'Outputs a random sentence. No args.'
}

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
      Plugins::Commands::Quit,
      Plugins::Commands::Info::Help,
      Plugins::Commands::Info::Src,
      Plugins::Commands::Info::Command,
      Plugins::Commands::Random::Word,
      Plugins::Commands::Random::Sentence
    ]
    c.plugins.prefix = /^\$/
    c
  end

  on :ban do |msg, ban|
    msg.reply("#{ban.by} just knocked the fuck out of #{ban.mask}")
  end

  on :unban do |msg, ban|
    msg.reply("And here I was thinking we were going to have some permanent " \
              "peace and quiet, but now #{ban.mask} is unbanned by #{ban.by}")
  end
end

bot.start
