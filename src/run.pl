#!usr/bin/perl

package SatanicBot;
use warnings;
use strict;
use diagnostics;
use SatanicBot::Bot;
use SatanicBot::Wiki;
use SatanicBot::WikiButt;

our $chan = '#FTB-Wiki';

our $bot = SatanicBot->new(
server    => 'irc.esper.net',
port      => '6667',
channels  => [$chan],

nick      => 'SatanicBot',
alt_nicks => ['SatanicButt', 'SatanicBooty'],
username  => 'SatanicBot',
name      => 'SatanicSanta\'s IRC bot'
);

$bot->run();
