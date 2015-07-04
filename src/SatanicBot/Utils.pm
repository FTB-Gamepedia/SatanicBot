# Copyright 2014 Eli Foster

package SatanicBot::Utils;
use warnings;
use strict;
use warnings;

my $ERROR = $!;

sub separate_by_commas {
    my ($self, $string) = @_;
    $string = reverse $string;
    $string =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    $string = reverse $string;
    return $string;
}

sub get_secure_contents {
    my $file = 'info/secure.txt';
    open my $fh, '<', $file or die "Could not open '$file' $ERROR\n";
    my @lines = <$fh>;
    close $fh;
    chomp @lines;
    return @lines;
}

1;
