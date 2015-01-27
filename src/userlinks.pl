# Copyright 2014 Eli Foster

use warnings;
use diagnostics;
use strict;
use MediaWiki::Bot qw(:constants);
use MediaWiki::API;
use SatanicBot::Utils;

my $ERRNO = $!;
my $mw = MediaWiki::Bot->new({
    protocol => 'http',
    host     => 'ftb.gamepedia.com',
    path     => q{/},
    operator => 'TheSatanicSanta',
    debug    => 2
});
my $mwapi = MediaWiki::API->new();
$mwapi->{config}->{api_url} = 'http://ftb.gamepedia.com/api.php';

login();
user();
#talk();
logout();

sub login{
    SatanicBot::Utils->get_secure_contents();
    #$mw->login({
    #    username => $lines[0],
    #    password => $lines[-1]
    #}) or die $mw->{error}->{code} . ": " . $mw->{error}->{details};
    $mwapi->login({
        lgname => $SatanicBot::Utils::LINES[0],
        lgpassword => $SatanicBot::Utils::LINES[1]
    }) or die $mwapi->{error}->{code} . ': ' . $mwapi->{error}->{details};
    return 1;
}

sub user{
    my $file = 'info/list_user.txt';
    open my $fh, '<', $file or die "Could not open $file $ERRNO\n";
    #my @lines = <$fh>;
    #chomp @lines;
    #my $things = join("\n", @lines);
    #my @newlines = split("\n", $things);
    #print "newlines variable has been set.\n";
    print "Starting loop...\n";
    while (my $line = <$fh>){
        #my $article = $_;
        chomp $line;
        my $text = $mw->get_text($line);
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
    $mw->logout();
    return 1;
}
