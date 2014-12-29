# Copyright 2014 Eli Foster

use warnings;
use diagnostics;
use strict;
use MediaWiki::Bot;
use Data::Dump;

print "What type?\n";
my $type = <>;

my $mw = MediaWiki::Bot->new({
    protocol => 'http',
    host     => 'ftb.gamepedia.com',
    path     => '/',
    operator => 'TheSatanicSanta',
    debug    => 2
});

my @users = $mw->what_links_here("User:SatanicSanta");
my @talks = $mw->what_links_here("User talk:SatanicSanta");

if ($type == 'user'){
    foreach (@users){
        Data::Dump->dump($_);
    }
}

if ($type == 'talk'){
    foreach (@talks){
        Data::Dump->dump($_);
    }
} else {
    print 'Please provide a valid type.';
    exit 0;
}

exit 0;
