# Copyright 2014 Eli Foster

package SatanicBot::MediaWikiAPI;
use warnings;
use strict;
use diagnostics;
use MediaWiki::API;
use SatanicBot::Bot;
use WWW::Mechanize;

my $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = 'http://ftb.gamepedia.com/api.php';
my $ERROR = $!;

sub login {
    SatanicBot::Utils->get_secure_contents();
    my $www = WWW::Mechanize->new();
    my $credentials = $www->get("http://ftb.gamepedia.com/api.php?action=login&lgname=$SatanicBot::Utils::LINES[0]&lgpassword=$SatanicBot::Utils::LINES[1]&format=json") or die "Unable to get url.\n";
    my $decode = $credentials->decoded_content();
    my @loggedin = $decode =~ m{\"result\":(.*?)\}};
    $mw->login( {
        lgname     => $SatanicBot::Utils::LINES[0],
        lgpassword => $SatanicBot::Utils::LINES[1]
    }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
    return 1;
}

sub edit_minor {
    my ($self, $name) = @_;
    my $minormods = "User:TheSatanicSanta/Sandbox/Minor Mods"; #change this
    my $ref = $mw->get_page({title => $minormods});
    my $content = $ref->{'*'};

    if ($content !~ m/\[\[$name\]\]/g) {
        #$content =~ s/\[\[Additional Buildcraft Objects\]\] \{\{\*\}\}/\[\[Additional Buildcraft Objects\]\] \{\{\*\}\}\n\[\[$name\]\] \{\{\*\}\}/;
        #my $filename = 'info/minor.txt';
        #open my $fh, '+>', $filename or die "Could not open $filename $!\n";
        #print $fh $content;
        #my @not_sorted = <$fh>;
        #my @sorted = sort @not_sorted;
        #print $fh @sorted;
        #close $fh;
        my $text = s/\[\[Additional Buildcraft Objects\]\] \{\{\*\}\}/\[\[Additional Buildcraft Objects\]\] \{\{\*\}\}\n\[\[$name\]\] \{\{\*\}\}/;
        $mw->edit( {
            action => 'edit',
            title  => $minormods,
            text   => $text,
            bot    => 1,
            minor  => 1
        }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};

        my $ref_presort = $mw->get_page({title => $minormods});
        my $content_presort = $ref_presort->{'*'};
        my @split = split /\n/, $content_presort;
        my @sort = sort @split;
        my $join = join @sort;
        $mw->edit( {
            action => 'edit',
            title  => $minormods,
            text   => $join,
            bot    => 1,
            minor  => 1
        }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
        return 1;
    } else {
        our $MINORCHECK = 'false';
        return 0;
    }
}

sub edit_gmods {
    my ($self, $abbrev, $name) = @_;
    my $gmods     = 'Template:G/Mods';
    my $gmodsdoc  = 'Template:G/Mods/doc';
    my $firstref  = $mw->get_page({title => $gmods});
    my $secondref = $mw->get_page({title => $gmodsdoc});
    my $replace_t = $firstref->{'*'};
    my $replace_d = $secondref->{'*'};

    if ($replace_d !~ m/\|\| <code>\$abbrev/) {
        if ($replace_d !~ m/\| \[\[\$name\]\]/) {
            $replace_t =~ s/\|#default/\|$abbrev = {{#if:{{{name\|}}}{{{code\|}}}\|\|_(}}{{#if:{{{name\|}}}{{{link\|}}}\|$name\|$abbrev}}{{#if:{{{name\|}}}{{{code\|}}}\|\|)}}\n\|$name = {{#if:{{{name\|}}}{{{code\|}}}\|\|_(}}{{#if:{{{name\|}}}{{{link\|}}}\|$name\|$abbrev}}{{#if:{{{name\|}}}{{{code\|}}}\|\|)}}\n\n\|#default/;
            $mw->edit( {
                action     => 'edit',
                title      => $gmods,
                text       => $replace_t,
                bot        => 1,
                minor      => 1
            }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};

            $replace_d =~ s/\|\}/\|-\n\| [[$name]] \|\| <code>$abbrev<\/code>\n\|\}/;
            $mw->edit( {
                action => 'edit',
                title  => $gmodsdoc,
                text   => $replace_d,
                bot    => 1,
                minor  => 1
            }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
            our $CHECK = 'true';
            return 1;
        } else {
            our $CHECK = 'false';
            return 0;
        }
    } else {
        our $CHECK = 'false';
        return 0;
    }
}

sub add_template {
    my ($self, $name) = @_;
    my $page = 'Feed The Beast Wiki:All templates';
    my $text = s/\|\}\n\n==Miscellaneous templates==/\|-\n\|\{\{Tl\|Navbox $name\}\} \|\| \[\[$name\]\] \|\|\n\|\|\}\n\n==Miscellaneous templates==/;
    $mw->edit( {
        action  => 'edit',
        title   => $page,
        text    => $text,
        bot     => 1,
        minor   => 1
    }) or die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
    return 1;
}

sub logout {
    $mw->logout();
    return 1;
}
1;
