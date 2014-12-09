# Copyright 2014 Eli Foster

use warnings;
use strict;
use diagnostics;

package SatanicBot::Wiki;
use MediaWiki::API;
use SatanicBot::Bot;

our $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = 'http://ftb.gamepedia.com/api.php';

sub login{
    my $file = 'info/secure.txt';
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
    my ($class, @words) = @_;
    my $gmods     = "Template:G/Mods";
    my $gmodsdoc  = "Template:G/Mods/doc";
    my $firstref  = $mw->get_page({title => $gmods});
    my $secondref = $mw->get_page({title => $gmodsdoc});
    my $replace_t = $firstref->{'*'};
    my $replace_d = $secondref->{'*'};

    unless ($firstref->{missing}){
        unless ($secondref->{missing}){
            if ($replace_d !~ m/\|\| <code>$words[1]/){
                if ($replace_d !~ m/\| [[$words[2]]]/){
                    $replace_t =~ s/\|#default/\|$words[1] = {{#if:{{{name\|}}}{{{code\|}}}\|\|_(}}{{#if:{{{name\|}}}{{{link\|}}}\|$words[2]\|$words[1]}}{{#if:{{{name\|}}}{{{code\|}}}\|\|)}}\n\|$words[2] = {{#if:{{{name\|}}}{{{code\|}}}\|\|_(}}{{#if:{{{name\|}}}{{{link\|}}}\|$words[2]\|$words[1]}}{{#if:{{{name\|}}}{{{code\|}}}\|\|)}}\n\n\|#default/;
                    $mw->edit({
                        action     => 'edit',
                        title      => $gmods,
                        text       => $replace_t,
                        bot        => 1,
                        minor      => 1
                    }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};

                    $replace_d =~ s/\|\}/\|-\n\| [[$words[2]]] \|\| <code>$words[1]<\/code>\n\|\}/;
                    $mw->edit({
                        action => 'edit',
                        title  => $gmodsdoc,
                        text   => $replace_d,
                        bot    => 1,
                        minor  => 1
                    }) || die $mw->{error}->{code} . ": " . $mw->{error}->{details};
                    return 1;
                } else { return 0; }
            } else { return 0; }
        }
    }
}

sub logout{
    $mw->logout();
}
return 1;
