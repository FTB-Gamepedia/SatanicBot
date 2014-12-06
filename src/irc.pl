use warnings;
use strict;

package SatanicBot;
use base qw(Bot::BasicBot);

my $bot = Bot::BasicBot->new(
  server    => 'irc.esper.net',
  port      => '6667',
  channels  => ['#FTB-Wiki', '#SatanicSanta'],

  nick      => 'SatanicBot',
  alt_nicks => ['SatanicButt', 'SatanicBooty'],
  username  => 'SatanicBot',
  name      => 'SatanicSanta\'s IRC bot'
);
$bot->run();

#Use this subroutine definition for adding commands.
sub said{
  my ($self, $message) = @_;
  if ($message->{body} == '$quit'){
    $bot->shutdown($bot->quit_message('Someone killed me!!'))
  }
  if ($message->{body} == '$addabbrv'){
    return 'Nigga that code ain\'t even work yet'
  }
}
