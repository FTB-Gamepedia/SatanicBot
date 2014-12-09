#!/usr/bin/perl
# Copyright 2014 Eli Foster

use warnings;
use strict;
use diagnostics;

package SatanicBot::WikiButt;
use MediaWiki::Bot;

my $mw = MediaWiki::Bot->new({
    host     => 'ftb.gamepedia.com',
    operator => 'TheSatanicSanta',
    debug    => 2
});

$mw->set_wiki({
    protocol => 'http',
    host     => 'ftb.gamepedia.com',
    path     => '/'
});

sub login{
    my $file = 'secure.txt';
    open my $fh, '<', $file or die "Could not open '$file' $!\n";
    my @lines = <$fh>;
    close $fh;
    chomp @lines;
    $mw->login({
        username => $lines[0],
        password => $lines[-1]
    });
}

sub upload{
    $mw->upload_from_url({
        url     => $SatanicBot::uploadwords[1],
        title   => $SatanicBot::uploadwords[2],
        summary => 'Uploading automatically from IRC'
    });
}

sub logout{
    $mw->logout();
}

return 1;
