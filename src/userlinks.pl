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
what();
logout();

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

sub what{
    #my $links  = $mw->what_links_here("User:SatanicSanta");
    #my $tlinks = $mw->what_links_here("User talk:SatanicSanta");

    my $firstref  = $mwapi->get_page({title => "User:TheSatanicSanta/Sandbox/userlinks"});
    my $secondref = $mwapi->get_page({title => "User:TheSatanicSanta/Sandbox/userlinks"});
    my $replace_user = $firstref->{'*'};
    my $replace_talk = $secondref->{'*'};

    $replace_user =~ s/[[User:SatanicSanta]]/[[User:TheSatanicSanta]]/;
    $replace_talk =~ s/[[User talk:SatanicSanta]]/[[User talk:TheSatanicSanta]]/;

    $mwapi->edit({
        action     => 'edit',
        title      => "User:TheSatanicSanta/Sandbox/userlinks",
        text       => $replace_user,
        bot        => 1,
        minor      => 1
    }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};

    $mwapi->edit({
        action     => 'edit',
        title      => "User:TheSatanicSanta/Sandbox/userlinks",
        text       => $replace_talk,
        bot        => 1,
        minor      => 1
    }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};

    #$mw->edit({
    #    page    => 'User:TheSatanicSanta/Sandbox/userlinks',
    #    text    => $replace_user,
    #    summary => 'Fixing old user page links',
    #    minor   => 1,
    #    bot     => 1
    #});

    #$mw->edit({
    #    page    => 'User:TheSatanicSanta/Sandbox/userlinks',
    #    text    => $replace_talk,
    #    summary => 'Fixing old talk page links',
    #    minor   => 1,
    #    bot     => 1
    #});
}

sub logout{
    $mw->logout();
}
