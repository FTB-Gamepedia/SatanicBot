# Copyright 2015 Eli Foster

use warnings;
use strict;
use diagnostics;
use Switch;
use MediawikiAPI::API;
use SatanicBot::Utils;

my $ERRNO = $!;
my $mw = MediawikiAPI::API->new();
$mw->base_url('http://skyrim.gamepedia.com/api.php');
login();

print "Races/Skills/Cities/Houses? (0/1/2/3)\n";
my $input = <>;
chomp $input;
edit($input);

sub login {
    my @login = SatanicBot::Utils->get_secure_contents();
    $mw->login($login[0], $login[1]);
    return 1;
}

sub get_file {
    my ($type) = @_;
    switch ($type) {
        case 0 {
            open my $rfh, '<', 'info/races.txt' or die "Could not open info/races.txt $ERRNO\n";
            return <$rfh>;
        }
        case 1 {
            open my $sfh, '<', 'info/skills.txt' or die "Could not open info/skills.txt $ERRNO\n";
            return <$sfh>;
        }
        case 2 {
            open my $cfh, '<', 'info/cities.txt' or die "Could not open info/cities.txt $ERRNO\n";
            return <$cfh>;
        }
        case 3 {
            open my $hfh, '<', 'info/houses.txt' or die "Could not open info/houses.txt $ERRNO\n";
            return <$hfh>;
        }
    }
}

sub edit {
    my ($type) = @_;
    my @possible_types = (0, 1, 2, 3);
    my %types = (
        0 => 'Races',
        1 => 'Skills',
        2 => 'Cities',
        3 => 'Houses'
    );

    #while (my $line = get_file($type)) {
    #    chomp $line;
    my $line = 'User:TheSatanicSanta/Sandbox/BotTesting';
        my $edit_summary = 'Preparing to move Navboxes to more consistent and easy-to-find names.';
        #my $ref = $mw->get_page({title => $line});
        #my $text = $ref->{'*'};
        my $text;
        unless ($type == 2) {
            $text =~ s/\{\{$type\}\}/\{\{Navbox $types{$type}\}\}/g;
            $mw->edit_page($line, $text, $edit_summary);
        } else {
            $text =~ s/\{\{$type nav\}\}/\{\{Navbox $types{2}\}\}/g;
            $mw->edit_page($line, $text, $edit_summary);
        }

    #    print "Page \'$line\' has been edited.\n";
    #}
    #close $fh;
    #print 'File closed.';
    return 1;
}
exit 0;
