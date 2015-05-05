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
    $ENV {PERL_LWP_SSL_VERIFY_HOSTNAME} = 0; #This is terrible.
    my $www = WWW::Mechanize->new();
    my $ui = $www->get("https://ftb.gamepedia.com/api.php?action=query&meta=userinfo&format=json");
    my $decode = $ui->decoded_content();
    if ($decode !~ m/\"id\"\:0/) {
        return 1;
    } else {
        my @secure = SatanicBot::Utils->get_secure_contents();
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
        $content =~ s/\n<!--/ \{\{\*\}\}\n\{\{L\|$name\}\}\n<!--/;
        my @split = split /\n/, $content;
        my @sort = sort { "\L$a" cmp "\L$b" } @split; # Should be case-insensitive sorting.
        my $join = join "\n", @sort;

        $join =~ s/\}\}\n\{\{L/\}\} \{\{\*\}\}\n\{\{/g;

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
        }) || return $mw->{error}->{code} . ': ' . $mw->{error}->{details};

        return 1;
    } else { return 0; }
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
        $content =~ s/\n<!--/ \{\{\*\}\}\n\{\{L\|$name\}\}\n<!--/;
        my @split = split /\n/, $content;
        my @sort = sort { "\L$a" cmp "\L$b" } @split;
        my $join = join "\n", @sort;

        $join =~ s/\}\}\n\{\{L/\}\} \{\{\*\}\}\n\{\{L/g;

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
    } else { return 0; }
}

sub edit_gmods {
    my ($self, $abbrv, $name) = @_;
    my $gmods   = 'Module:Mods/list';
    my $ref     = $mw->get_page({title => $gmods});
    my $content = $ref->{'*'};
    $name =~ s/\'/\\'/g;

    if ($content !~ m/\s$abbrv = /) {
        if ($content !~ m/\{\'$name\'/) {
            $content =~ s/local modsByAbbrv = \{/local modsByAbbrv = \{\n    $abbrv = \{\'$name\', \[=\[<translate>$name<\/translate>\]=\]\},/;
            $mw->edit( {
                action => 'edit',
                title  => $gmods,
                text   => $content,
                bot    => 1,
                minor  => 1
            }) || return $mw->{error}->{code} . ': ' . $mw->{error}->{details};

            return 1;
        } else { return 0; }
    } else { return 0; }
}

sub add_template {
    my ($self, $name) = @_;
    my $page = 'Template:Navbox List';
    my $ref = $mw->get_page({title => $page});
    my $content = $ref->{'*'};

    if ($content !~ m/\{\{Tl\|Navbox $name\}\}/ or $content !~ m/\{\{L\|$name\}\}/) {
        $content =~ s/\|\}/\|-\n| \{\{Tl\|Navbox $name\}\} \|\| \{\{L\|$name\}\} \|\|\n\|\}/;
        $mw->edit( {
            action  => 'edit',
            title   => $page,
            text    => $content,
            bot     => 1,
            minor   => 1
        }) or die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
        return 1;
    } else { return 0; }
}

sub create_mod_category {
    my ($self, $name) = @_;
    my $page = "Category:$name";
    $mw->edit( {
        action => 'edit',
        title  => $page,
        text   => "[[Category:Mod categories]]\n[[Category:Mods]]",
        bot    => 1
    }) or die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
    return 1;
}

sub create_minor_category {
    my ($self, $name) = @_;
    my $page = "Category:$name";
    $mw->edit( {
        action => 'edit',
        title  => $page,
        text   => "[[Category:Mod categories]]\n[[Category:Minor Mods]]",
        bot    => 1
    }) or die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
    return 1;
}

sub check_page {
    my ($self, $page) = @_;
    my $ref = $mw->get_page( { title => $page } );
    if (exists $ref->{missing}) { #If the page does NOT exist, it returns 0. Else 1
        return 0;
    } else { return 1; }
}

sub logout {
    $mw->logout();
    return 1;
}
1;
