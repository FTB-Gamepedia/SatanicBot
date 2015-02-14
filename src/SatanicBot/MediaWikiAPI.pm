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
    my $www = WWW::Mechanize->new();
    my $ui = $www->get("http://ftb.gamepedia.com/api.php?action=query&meta=userinfo&format=json");
    my $decode = $ui->decoded_content();
    if ($decode !~ m/\"id\"\:0/) {
        return 1;
    } else {
        my @secure = SatanicBot::Utils->get_secure_contents();
        #This is removed because it's broken or something.
        #my $www = WWW::Mechanize->new();
        #my $credentials = $www->get("http://ftb.gamepedia.com/api.php?action=login&lgname=$secure[0]&lgpassword=$secure[1]&format=json") or die "Unable to get url.\n";
        #my $decode = $credentials->decoded_content();
        #my @loggedin = $decode =~ m{\"result\":(.*?)\}};
        $mw->login( {
            lgname     => $secure[0],
            lgpassword => $secure[1]
        }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
        return 1;
    }
}


sub edit_minor {
    my ($self, $name) = @_;
    my $minormods = 'Template:Minor Mods';
    my $ref = $mw->get_page({title => $minormods});
    my $content = $ref->{'*'};
    my $editref = $mw->get_page({ title => $name });

    if (exists $editref->{missing}) {
        return 0;
    } elsif ($content !~ m/\[\[$name\]\]/g) {
        $content =~ s/\n<!--/ \{\{\*\}\}\n\[\[$name\]\]\n<!--/;
        my @split = split /\n/, $content;
        my @sort = sort { "\L$a" cmp "\L$b" } @split; # Should be case-insensitive sorting.
        my $join = join "\n", @sort;

        $join =~ s/\]\]\n\[\[/\]\] \{\{\*\}\}\n\[\[/g;

        # I need to remove it then add it again because it gets sorted wrong.
        $join =~ s/\<!-- DO NOT EDIT THIS LINE -->//;
        $join = $join . "\n<!-- DO NOT EDIT THIS LINE -->";
        $join =~ s/ \{\{\*\}\}\n<!--/\n<!--/;
        $join =~ s/^\n//;

        $mw->edit( {
            action => 'edit',
            title  => $minormods,
            text   => $join,
            bot    => 1,
            minor  => 1
        }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};

        return 1;
    } else {
        return 0;
    }
}

sub edit_mods {
    my ($self, $name) = @_;
    my $mods = 'Template:Mods';
    my $ref = $mw->get_page({title => $mods});
    my $content = $ref->{'*'};
    my $editref = $mw->get_page({ title => $name });

    if (exists $editref->{missing}) {
        return 0;
    } elsif ($content !~ m/\[\[$name\]\]/g) {
        $content =~ s/\n<!--/ \{\{\*\}\}\n\[\[$name\]\]\n<!--/;
        my @split = split /\n/, $content;
        my @sort = sort { "\L$a" cmp "\L$b" } @split;
        my $join = join "\n", @sort;

        $join =~ s/\]\]\n\[\[/\]\] \{\{\*\}\}\n\[\[/g;

        #See comment in edit_minor.
        $join =~ s/<!-- DO NOT EDIT THIS LINE -->//;
        $join = $join . "\n<!-- DO NOT EDIT THIS LINE -->";
        $join =~ s/ \{\{\*\}\}\n<!--/\n<!--/;
        $join =~ s/^\n//;

        $mw->edit( {
            action => 'edit',
            title  => $mods,
            text   => $join,
            bot    => 1,
            minor  => 1
        }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};

        return 1;
    } else {
        return 0;
    }
}

sub edit_gmods {
    my ($self, $abbrv, $name) = @_;
    my $gmods   = 'User:TheSatanicSanta/Sandbox/Bot';
    my $ref     = $mw->get_page({title => $gmods});
    my $replace = $ref->{'*'};
    $name =~ s/\'/\\'/g;

    if ($replace !~ m/$abbrv = /) {
        if ($replace !~ m/\{\'$name\'/) {
            $replace =~ s/local modsByAbbrv = \{/local modsByAbbrv = \{\n    $abbrv = \{\'$name\', \[=\[<translate>$name<\/translate>\]=\]\},/;
            $mw->edit( {
                action     => 'edit',
                title      => $gmods,
                text       => $replace,
                bot        => 1,
                minor      => 1
            }) || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};

            return 1;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

#This is not yet functional.
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
