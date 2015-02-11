# Copyright 2014 Eli Foster

use warnings;
use diagnostics;
use strict;
use MediaWiki::API;
use SatanicBot::Utils;

my $ERRNO = $!;
my $mwapi = MediaWiki::API->new();
$mwapi->{config}->{api_url} = 'http://ftb.gamepedia.com/api.php';

login();
user();
#talk();
logout();

sub login{
    my @login = SatanicBot::Utils->get_secure_contents();
    $mwapi->login({
        lgname => $login[0],
        lgpassword => $login[1]
    }) or die $mwapi->{error}->{code} . ': ' . $mwapi->{error}->{details};
    return 1;
}

sub user{
    my $file = 'info/list_user.txt';
    open my $fh, '<', $file or die "Could not open $file $ERRNO\n";
    print "Starting loop...\n";
    while (my $line = <$fh>){
        chomp $line;
        my $ref = $mwapi->get_page({title => $line});
        my $text = $ref->{'*'};
        $text =~ s/\{\{U\|SatanicSanta/\{\{U\|TheSatanicSanta/g;

        print "Text and article variables have been set.\n";
        eval {
            $mwapi->edit({
                action => 'edit',
                title  => $line,
                text   => $text,
                bot    => 1,
                minor  => 1
            })
        };
        if ($@) {
            print $mwapi->{error}->{code} . ': ' . $mwapi->{error}->{details};
            continue;
        }
        print "Page \'$line\' has been edited.\n";
    }
    close $fh;
    print 'File closed.';
    return 1;
}

sub talk{
#    my @tlinks = ($mw->what_links_here("User talk:SatanicSanta"));
#
#    foreach (@tlinks){
#        my $talk_ref = $mwapi->get_page({title => $_});
#        my $replace_talk = $talk_ref->{'*'};
#
#        $replace_talk =~ s/\[\[User talk:SatanicSanta\]\]/\[\[User talk:TheSatanicSanta\]\]/;
#    }
}

sub logout{
    $mwapi->logout();
    return 1;
}
