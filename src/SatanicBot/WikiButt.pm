# Copyright 2014 Eli Foster

use warnings;
use strict;
use diagnostics;

package SatanicBot::WikiButt;
use MediaWiki::Bot;
use SatanicBot::Bot;

my $mw = MediaWiki::Bot->new({
    protocol => 'https',
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
    my ($self, $url, $title) = @_;
    $mw->upload_from_url({
        url     => $url,
        title   => $title,
        summary => 'Uploading automatically from IRC'
    }) or die "Upload failed!";
}

sub count_contribs{
    my ($self, $username) = @_;
    my $count = $mw->count_contributions($username);
}

sub logout{
    $mw->logout();
}

return 1;
