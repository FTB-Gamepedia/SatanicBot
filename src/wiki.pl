#!/usr/bin/perl
use warnings;
use diagnostics;

package Wiki;
use MediaWiki::API;

my $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = 'http://ftb.gamepedia.com/api.php';

sub login{
  my $file = 'secure.txt';
  open my $fh, '<', $file or die "Could not open '$file' $!\n";
  @lines = <$fh>;
  close $fh;
  chomp @lines;
  $mw->login({
    lgname     => $lines[0],
    lgpassword => $lines[-1]
  }) || die $mw->{error}->{code} . ": " . $mw->{error}->{details};
}

sub edit_gmods{
  my $gmods     = "Template:G/Mods";
  my $gmodsdoc  = "Template:G/Mods/doc";
  my $firstref  = $mw->get_page({title => $gmods});
  my $secondref = $mw->get_page({title => $gmodsdoc});

  unless ($firstref->{missing}){
    $mw->edit({
      action     => 'edit',
      title      => $gmods,
      appendtext => "\n\n|$SatanicBot::words[1] = {{#if:{{{name|}}}{{{code|}}}||_(}}{{#if:{{{name|}}}{{{link|}}}|$SatanicBot::words[2]|$SatanicBot::words[1]}}{{#if:{{{name|}}}{{{code|}}}||)}}\n|$SatanicBot::words[2] = {{#if:{{{name|}}}{{{code|}}}||_(}}{{#if:{{{name|}}}{{{link|}}}|$SatanicBot::words[2]|$SatanicBot::words[1]}}{{#if:{{{name|}}}{{{code|}}}||)}}",#$firstref->{'*'} . "\n|" + modname + " = {{#if:{{{name|}}}{{{code|}}}||_(}}{{#if:{{{name|}}}{{{link|}}}|" + name + "|" + abbrev + "}}{{#if:{{{name|}}}{{{code|}}}||)}}" #figure out how to do stuff with that python script
      bot        => 1
    }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
  }

  unless ($secondref->{missing}){
    $mw->edit({
      action     => 'edit',
      title      => $gmodsdoc,
      appendtext => "\n* [[$SatanicBot::words[2]]]: <code>$SatanicBot::words[1]</code>",#$secondref->{'*'} . "\n* [[" + modname "]]: <code>" + abbrv + "</code>"
      bot        => 1
    }) || die $mw->{error}->{code} . ": " . $mw->{error}->{details};
  }
}

sub logout{
  $mw->logout();
}
return 1;
