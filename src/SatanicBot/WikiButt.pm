# Copyright 2014 Eli Foster

use warnings;
use strict;
use diagnostics;

package SatanicBot::WikiButt;
use MediaWiki::Bot;
use SatanicBot::Bot;

my $mw = MediaWiki::Bot->new({
    protocol => 'http',
    host     => 'ftb.gamepedia.com',
    path     => '/',
    operator => 'TheSatanicSanta',
    debug    => 2
});

sub login{
    my $file = 'info/secure.txt';
    open my $fh, '<', $file or die "Could not open '$file' $!\n";
    my @lines = <$fh>;
    close $fh;
    chomp @lines;
    $mw->login({
        username => $lines[0],
        password => $lines[-1]
    }) or die "Login failed!";
}

sub upload{
    $mw->upload_from_url({
        url     => $SatanicBot::Bot::uploadwords[1],
        title   => $SatanicBot::Bot::uploadwords[2],
        summary => 'Uploading automatically from IRC'
    }) or die "Upload failed!";
}

sub logout{
    $mw->logout();
}

return 1;
