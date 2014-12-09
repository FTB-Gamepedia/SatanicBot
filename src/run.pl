#!usr/bin/perl

use warnings;
use strict;
use diagnostics;
use SatanicBot::Bot;
use SatanicBot::Wiki;
use SatanicBot::WikiButt;
use Bot::BasicBot;

our $chan = '#FTB-Wiki';

our $bot = SatanicBot::Bot->new(
server    => 'irc.esper.net',
port      => '6667',
channels  => [$chan],

nick      => 'SatanicBot',
alt_nicks => ['SatanicButt', 'SatanicBooty'],
username  => 'SatanicBot',
name      => 'SatanicSanta\'s IRC bot'
);

$bot->run();
