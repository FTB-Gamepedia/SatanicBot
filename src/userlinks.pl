#!/usr/bin/perl
# Copyright 2014 Eli Foster

use warnings;
use diagnostics;
use strict;
use MediaWiki::Bot;
use MediaWiki::EditFramework;

my $mw = MediaWiki::Bot->new({
    protocol => 'http',
    host     => 'ftb.gamepedia.com',
    path     => '/',
    operator => 'TheSatanicSanta',
    debug    => 2
});

my $mwef = MediaWiki::EditFramework->new('ftb.gamepedia.com', '/');

login();

my @links  = $mw->what_links_here("User:SatanicSanta", undef, 0, {hook => \&user});

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
}

sub user{
    my ($stuff) = @_;

    foreach my $thing (@$stuff){
        my $user_ref = $mwef->get_page($thing);
        my $replace_user = $user_ref->get_text;

        $replace_user =~ s/\[\[User:SatanicSanta\]\]/\[\[User:TheSatanicSanta\]\]/g;

        $user_ref->edit($replace_user, 'Fixing user links.');
    }
}

sub talk{
    #my @tlinks = ($mw->what_links_here("User talk:SatanicSanta"));
#
#    foreach (@tlinks){
#        my $talk_ref = $mwapi->get_page({title => $_});
#        my $replace_talk = $talk_ref->{'*'};
#
#        $replace_talk =~ s/\[\[User talk:SatanicSanta\]\]/\[\[User talk:TheSatanicSanta\]\]/;
#    }
}

sub logout{
    $mw->logout();
}
