#!/usr/bin/perl
# Copyright 2014 Eli Foster

use warnings;
use diagnostics;
use strict;
use MediaWiki::Bot;

my $mw = MediaWiki::Bot({
    host     => 'ftb.gamepedia.com',
    operator => 'TheSatanicSanta',
    debug    => 2
});
login();
what();
logout();

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

sub what{
    my @links  = $mw->what_links_here("User:SatanicSanta");
    my @tlinks = $mw->what_links_here("User talk:SatanicSanta");

    #This does not work.
    my $text  = $mw->get_text(@{$links});
    my $ttext = $mw->get_text(@{$tlinks});

    $text  =~ s/[[User:SatanicSanta]]/[[User:TheSatanicSanta]]/;
    $ttext =~ s/[[User talk:SatanicSanta]]/[[User talk:TheSatanicSanta]]/;

    $mw->edit({
        page => @links,
        text => $text,
        summary => 'Fixing old user page links',
        minor => 1,
        bot => 1
    });

    $mw->edit({
        page    => @tlinks,
        text    => $ttext,
        summary => 'Fixing old talk page links',
        minor   => 1,
        bot     => 1
    });
}

sub logout{
    $mw->logout();
}
