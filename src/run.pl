# Copyright 2014 Eli Foster

use warnings;
use strict;
use diagnostics;
use SatanicBot::Bot;
use Bot::BasicBot;

my $chan = '#FTB-Wiki';
my $nick = 'LittleHelper';

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
