#!/usr/bin/perl
# Copyright 2014 Eli Foster

use warnings;
use diagnostics;
use strict;
use MediaWiki::Bot;
use MediaWiki::API;

my $mw = MediaWiki::Bot->new({
    protocol => 'http',
    host     => 'ftb.gamepedia.com',
    path     => '/',
    operator => 'TheSatanicSanta',
    debug    => 2
});
my $mwapi = MediaWiki::API->new();
$mwapi->{config}->{api_url} = 'http://ftb.gamepedia.com/api.php';
login();
user();
sleep(30);
talk();
logout();
exit;

sub login{
    my $file = 'info/secure.txt';
    open my $fh, '<', $file or die "Could not open '$file' $!\n";
    my @lines = <$fh>;
    close $fh;
    chomp @lines;
    $mw->login({
        username => $lines[0],
        password => $lines[-1]
    });
    $mwapi->login({
        lgname     => $lines[0],
        lgpassword => $lines[-1]
    });
}

sub user{
    my @links  = ($mw->what_links_here("User:SatanicSanta"));

    foreach (@links){
        my $user_ref = $mwapi->get_page({title => $_});
        my $replace_user = $user_ref->{'*'};

        $replace_user =~ s/\[\[User:SatanicSanta\]\]/\[\[User:TheSatanicSanta\]\]/;

        $mwapi->edit({
            action     => 'edit',
            title      => $_,
            text       => $replace_user,
            bot        => 1,
            minor      => 1
        }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
    }
}

sub talk{
    my @tlinks = ($mw->what_links_here("User talk:SatanicSanta"));

    foreach (@tlinks){
        my $talk_ref = $mwapi->get_page({title => $_});
        my $replace_talk = $talk_ref->{'*'};

        $replace_talk =~ s/\[\[User talk:SatanicSanta\]\]/\[\[User talk:TheSatanicSanta\]\]/;

        $mwapi->edit({
            action     => 'edit',
            title      => $_,
            text       => $replace_talk,
            bot        => 1,
            minor      => 1
        }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
    }
}

sub logout{
    $mw->logout();
}
