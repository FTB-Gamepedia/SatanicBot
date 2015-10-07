# Copyright 2015 Eli Foster

use warnings;
use strict;
use diagnostics;

use Bot::BasicBot;

use Cwd qw(abs_path);
use FindBin;
use lib abs_path("$FindBin::Bin");
use SatanicBot::Bot;

my $channels = ['#SatanicSanta', '#FTB-Wiki', '#FTB-Wiki-Dev'];
my $nick     = 'LittleHelper';

my $bot = SatanicBot::Bot->new(
  server    => 'irc.esper.net',
  port      => '6667',
  channels  => [$chan],
  nick      => $nick,
  alt_nicks => ['SatanicButt', 'SatanicBooty'],
  username  => 'SatanicBot',
  name      => 'SatanicSanta\'s IRC bot'
);

$bot->run();
