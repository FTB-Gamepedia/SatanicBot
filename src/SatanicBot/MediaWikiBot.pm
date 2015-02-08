# Copyright 2014 Eli Foster

package SatanicBot::MediaWikiBot;
use warnings;
use strict;
use diagnostics;
use MediaWiki::Bot;
use SatanicBot::Bot;
use SatanicBot::Utils;

my $mw = MediaWiki::Bot->new( {
    protocol => 'http',
    host     => 'ftb.gamepedia.com',
    path     => q{/},
    operator => 'TheSatanicSanta',
    debug    => 2
});
my $ERROR = $!;

sub login {
    my @secure = SatanicBot::Utils->get_secure_contents();
    $mw->login( {
        username => $secure[0],
        password => $secure[1]
    }) or die "Login failed! $mw->{error}->{code}: $mw->{error}->{details}";
    return 1;
}

sub upload {
    my ($self, $url, $title) = @_;
    $mw->upload_from_url( {
        url     => $url,
        title   => $title
    }) or die "Upload failed! $mw->{error}->{code}: $mw->{error}->{details}";
    return 1;
}

sub logout {
    $mw->logout();
    return 1;
}
1;
