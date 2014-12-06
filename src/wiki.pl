#!/usr/bin/perl
use warnings;
use diagnostics;

package Wiki;
use MediaWiki::API;
use JSON;

my $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = 'http://ftb.gamepedia.org/api.php';
open FILE, 'config.json' or die "Could not open json!";
sysread(FILE, my $thing, -s FILE);
close FILE or die "Could not close json!";
my $decoded = decode_json($thing);

sub login{
  $mw->login(
    lgname     => $decoded->{'username'},
    lgpassword => $decoded->{'password'}
  );
}

sub edit_gmods{
  #remove the User:TheSatanicSanta/ from them once you know it works.
  my $gmods = "User:TheSatanicSanta/Template:G/Mods";
  my $gmodsdoc = "User:TheSatanicSanta/Template:G/Mods/doc";
  my $firstref = $mw->get_page({title => $gmods});
  my $secondref = $mw->get_page({title => $gmodsdoc});

  unless ($firstref->{missing}){
    $mw->edit({
      action => 'edit',
      title  => $gmods,
      text   => 'Weeee'#$firstref->{'*'} . "\n|" + modname + " = {{#if:{{{name|}}}{{{code|}}}||_(}}{{#if:{{{name|}}}{{{link|}}}|" + name + "|" + abbrev + "}}{{#if:{{{name|}}}{{{code|}}}||)}}" #figure out how to do stuff with that python script
    }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
  }

  unless ($secondref->{missing}){
    $mw->edit({
      action => 'edit',
      title  => $gmodsdoc,
      text   => 'Weeee'#$secondref->{'*'} . "\n* [[" + modname "]]: <code>" + abbrv + "</code>"
    }) || die $mw->{error}->{code} . ": " . $mw->{error}->{details};
  }
}
return 1;
