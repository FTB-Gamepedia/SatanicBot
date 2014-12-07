#!/usr/bin/perl
use warnings;
use strict;
use diagnostics;

package Wiki;
use MediaWiki::API;

my $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = 'http://ftb.gamepedia.com/api.php';

sub login{
  my $file = 'secure.txt';
  open my $fh, '<', $file or die "Could not open '$file' $!\n";
  my @lines = <$fh>;
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
  my $replace_t = $firstref->{'*'};
  my $replace_d = $secondref->{'*'};

  unless ($firstref->{missing}){
    $replace_t =~ s/\|#default/\|$SatanicBot::words[1] = {{#if:{{{name\|}}}{{{code\|}}}\|\|_(}}{{#if:{{{name\|}}}{{{link\|}}}\|$SatanicBot::words[2]\|$SatanicBot::words[1]}}{{#if:{{{name\|}}}{{{code\|}}}\|\|)}}\n\|$SatanicBot::words[2] = {{#if:{{{name\|}}}{{{code\|}}}\|\|_(}}{{#if:{{{name\|}}}{{{link\|}}}\|$SatanicBot::words[2]\|$SatanicBot::words[1]}}{{#if:{{{name\|}}}{{{code\|}}}\|\|)}}\n\n\|#default/;
    $mw->edit({
      action     => 'edit',
      title      => $gmods,
      text       => $replace_t,
      bot        => 1,
      minor      => 1
    }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
  }

  unless ($secondref->{missing}){
    $replace_d =~ s/\|\}/\|-\n\| [[$SatanicBot::words[2]]] \|\| <code>$SatanicBot::words[1]<\/code>\n\|\}/;
    $mw->edit({
      action => 'edit',
      title  => $gmodsdoc,
      text   => $replace_d,
      bot    => 1,
      minor  => 1
    }) || die $mw->{error}->{code} . ": " . $mw->{error}->{details};
  }
}

sub logout{
  $mw->logout();
}
return 1;
