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
    SatanicBot::Utils->get_secure_contents();
    $mw->login( {
        username => $SatanicBot::Utils::LINES[0],
        password => $SatanicBot::Utils::LINES[1]
    }) or die 'Login failed!';
    return 1;
}

sub upload {
    $mw->upload_from_url( {
        url     => $SatanicBot::Bot::uploadwords[1],
        title   => $SatanicBot::Bot::uploadwords[2]
    }) or die 'Upload failed!';
    return 1;
}

sub logout {
    $mw->logout();
    return 1;
}
1;
