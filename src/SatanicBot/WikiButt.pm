# Copyright 2014 Eli Foster

package SatanicBot::WikiButt;
use warnings;
use strict;
use diagnostics;
use MediaWiki::Bot;
use SatanicBot::Bot;

my $mw = MediaWiki::Bot->new({
    protocol => 'http',
    host     => 'ftb.gamepedia.com',
    path     => q{/},
    operator => 'TheSatanicSanta',
    debug    => 2
});

sub login{
    my $file = 'info/secure.txt';
    open my $fh, '<', $file or die "Could not open '$file' $ERRNO\n";
    my @lines = <$fh>;
    close $fh;
    chomp @lines;
    $mw->login({
        username => $lines[0],
        password => $lines[-1]
    }) or die 'Login failed!';
    return 1;
}

sub upload{
    $mw->upload_from_url({
        url     => $SatanicBot::Bot::uploadwords[1],
        title   => $SatanicBot::Bot::uploadwords[2]
    }) or die 'Upload failed!';
    return 1;
}

sub logout{
    $mw->logout();
    return 1;
}
1;
