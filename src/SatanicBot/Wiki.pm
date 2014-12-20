# Copyright 2014 Eli Foster

use warnings;
use strict;
use diagnostics;

package SatanicBot::Wiki;
use MediaWiki::API;
use SatanicBot::Bot;
use WWW::Mechanize;

our $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = 'http://ftb.gamepedia.com/api.php';

sub login{
    my $file = 'info/secure.txt';
    open my $fh, '<', $file or die "Could not open '$file' $!\n";
    my @lines = <$fh>;
    close $fh;
    chomp @lines;
    my $www = WWW::Mechanize->new();
    my $credentials = $www->get("http://ftb.gamepedia.com/api.php?action=login&lgname=$lines[0]&lgpassword=$lines[-1]&format=json") or die "Unable to get url.\n";
    my $decode = $credentials->decoded_content();
    my @loggedin = $decode =~ m{\"result\":(.*?)\}};
    if ($loggedin[0] eq 'NeedToken'){
        $mw->login({
            lgname     => $lines[0],
            lgpassword => $lines[-1]
        }) || die $mw->{error}->{code} . ": " . $mw->{error}->{details};
    }
}

sub edit_gmods{
    my ($self, $abbrev, $name) = @_;
    my $gmods     = "Template:G/Mods";
    my $gmodsdoc  = "Template:G/Mods/doc";
    my $firstref  = $mw->get_page({title => $gmods});
    my $secondref = $mw->get_page({title => $gmodsdoc});
    my $replace_t = $firstref->{'*'};
    my $replace_d = $secondref->{'*'};

    if ($replace_d !~ m/\|\| <code>$abbrev/){
        if ($replace_d !~ m/\| [[$name]]/){
            $replace_t =~ s/\|#default/\|$abbrev = {{#if:{{{name\|}}}{{{code\|}}}\|\|_(}}{{#if:{{{name\|}}}{{{link\|}}}\|$name\|$abbrev}}{{#if:{{{name\|}}}{{{code\|}}}\|\|)}}\n\|$name = {{#if:{{{name\|}}}{{{code\|}}}\|\|_(}}{{#if:{{{name\|}}}{{{link\|}}}\|$name\|$abbrev}}{{#if:{{{name\|}}}{{{code\|}}}\|\|)}}\n\n\|#default/;
            $mw->edit({
                action     => 'edit',
                title      => $gmods,
                text       => $replace_t,
                bot        => 1,
                minor      => 1
            }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};

            $replace_d =~ s/\|\}/\|-\n\| [[$name]] \|\| <code>$abbrev<\/code>\n\|\}/;
            $mw->edit({
                action => 'edit',
                title  => $gmodsdoc,
                text   => $replace_d,
                bot    => 1,
                minor  => 1
            }) || die $mw->{error}->{code} . ": " . $mw->{error}->{details};
            our $check = 'true';
            return 1;
        } else {
            our $check = 'false';
            return 0;
        }
    } else {
        our $check = 'false';
        return 0;
    }
}

sub logout{
    $mw->logout();
}
return 1;
