#!/usr/bin/perl
# Copyright 2014 Eli Foster

use warnings;
use diagnostics;
use strict;
use MediaWiki::Bot qw(:constants);
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

sub login{
    my $file = 'info/secure.txt';
    open my $fh, '<', $file or die "Could not open '$file' $!\n";
    my @lines = <$fh>;
    close $fh;
    chomp @lines;
    #$mw->login({
    #    username => $lines[0],
    #    password => $lines[-1]
    #}) or die $mw->{error}->{code} . ": " . $mw->{error}->{details};
    $mwapi->login({
        lgname => $lines[0],
        lgpassword => $lines[-1]
    }) or die $mwapi->{error}->{code} . ": " . $mwapi->{error}->{details};
    user();
}

sub user{
    my $file = 'info/list_user.txt';
    open my $fh, '<', $file or die "Could not open $file $!\n";
    my @lines = <$fh>;
    chomp @lines;
    my $things = join("\n", @lines);
    my @newlines = split("\n", $things);
    print "newlines variable has been set.\n";
    foreach (@newlines){
        my $article = $_;
        my $text = $mw->get_text($article);
        $text =~ s/\{\{U\|SatanicSanta/\{\{U\|TheSatanicSanta/g;

        print "Text and article variables have been set.\n";
        $mwapi->edit({
            action => 'edit',
            title  => $article,
            text   => $text,
            bot    => 1,
            minor  => 1
        }) or die $mwapi->{error}->{code} . ": " . $mwapi->{error}->{details};
        print "Page \'$article\' has been edited.\n";
    }
    close $fh;
    print "File closed.";
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
