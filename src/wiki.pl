#!/usr/bin/perl

use MediaWiki::API;

my $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = 'http://ftb.gamepedia.org/api.php';

$mw->( { lgname => 'SatanicBot', lgpassword => 'fill this in after talking to peter on how he did it'});
  || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};

#remove the User:TheSatanicSanta/ from them once you know it works.
my $gmods = "User:TheSatanicSanta/Template:G/Mods";
my $gmodsdoc = "User:TheSatanicSanta/Template:G/Mods/doc";
my $firstref = $mw->get_page({title => $gmods});
my $secondref = $mw->get_page({title => $gmodsdoc});
unless ($firstref->{missing}){
  $mw->edit({
    action => 'edit',
    title  => $gmods,
    text   => $firstref->{'*'} . "\n|" + modname + " = {{#if:{{{name|}}}{{{code|}}}||_(}}{{#if:{{{name|}}}{{{link|}}}|" + name + "|" + abbrev + "}}{{#if:{{{name|}}}{{{code|}}}||)}}" #figure out how to do stuff with that python script
  }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
}
unless ($secondref->{missing}){
  $mw->edit({
    action => 'edit',
    title  => $gmodsdoc,
    text   => $secondref->{'*'} . "\n* [[" + modname "]]: <code>" + abbrv + "</code>"
  }) || die $mw->{error}->{code} . ": " . $mw->{error}->{details};
}
