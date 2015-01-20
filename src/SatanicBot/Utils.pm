# Copyright 2014 Eli Foster

package SatanicBot::Utils;
use warnings;
use strict;
use warnings;

my $ERROR = $!;

sub separate_by_commas {
    my ($string) = @_;
    $string = reverse $string;
    $string =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    $string = reverse $string;
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
