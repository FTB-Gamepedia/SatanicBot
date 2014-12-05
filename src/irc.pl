use warnings;
use strict;

package SatanicBot;
use Bot::BasicBot 'basicButt';
use Acme::Comment type => 'C++';

my $bot = basicButt->new(
  server    => 'irc.esper.net',
  port      => '6667',
  channels  => ['#FTB-Wiki', '#SatanicSanta'],

  nick      => 'SatanicBot',
  alt_nicks => ['SatanicButt', 'SatanicBooty'],
  username  => 'SatanicBot',
  name      => 'SatanicSanta\'s IRC bot'
);
$bot->run();

if (basicButt->said(who, raw_nick, channel, '$quit', address){
  $bot->shutdown($bot->quit_message('Someone killed me!!'));
}
