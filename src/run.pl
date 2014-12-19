#!usr/bin/perl

use warnings;
use strict;
use diagnostics;
use SatanicBot::Bot;
use SatanicBot::Wiki;
use SatanicBot::WikiButt;
use Bot::BasicBot;

my @ARGV;

if ($ARGV[1] eq 'dev'){
    my $chan = '#SatanicSanta';
    my $nick = 'LittleHelper|dev';

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
} else {
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
}
