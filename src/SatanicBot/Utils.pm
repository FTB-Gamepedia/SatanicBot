# Copyright 2014 Eli Foster

package SatanicBot::Utils;
use warnings;
use strict;
use warnings;

my $ERROR = $!;

sub separate_with_commas {

}

sub get_secure_contents {
    my $file = 'info/secure.txt';
    open my $fh, '<', $file or die "Could not open '$file' $ERROR\n";
    our @LINES = <$fh>;
    close $fh;
    chomp @LINES;
    return 1;
}
1;
