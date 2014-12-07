#!/usr/bin/perl
use warnings;
use diagnostics;

package Wiki;
use MediaWiki::API;

my $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = 'http://ftb.gamepedia.com/api.php';

my $file = 'secure.txt';
open my $fh, '<', $file or die "Could not open '$file' $!\n";

while (<$fh>){
  my $username = $_ if /\ba\b/;
  my $password = $_ if /\b1\b/;
}

sub login{
  $mw->login({
    lgname     => $username,
    lgpassword => $password
  }) || die $mw->{error}->{code} . ": " . $mw->{error}->{details};
}

sub edit_gmods{
  #remove the User:TheSatanicSanta/ from them once you know it works.
  my $gmods     = "User:TheSatanicSanta/Sandbox/Template";
  my $gmodsdoc  = "User:TheSatanicSanta/Sandbox/doc";
  my $firstref  = $mw->get_page({title => $gmods});
  my $secondref = $mw->get_page({title => $gmodsdoc});

  unless ($firstref->{missing}){
    $mw->edit({
      action => 'edit',
      title  => $gmods,
      text   => 'This is an automated test'#$firstref->{'*'} . "\n|" + modname + " = {{#if:{{{name|}}}{{{code|}}}||_(}}{{#if:{{{name|}}}{{{link|}}}|" + name + "|" + abbrev + "}}{{#if:{{{name|}}}{{{code|}}}||)}}" #figure out how to do stuff with that python script
    }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
  }

  unless ($secondref->{missing}){
    $mw->edit({
      action => 'edit',
      title  => $gmodsdoc,
      text   => 'This is an automated test'#$secondref->{'*'} . "\n* [[" + modname "]]: <code>" + abbrv + "</code>"
    }) || die $mw->{error}->{code} . ": " . $mw->{error}->{details};
  }
}
return 1;
