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

sub get_contribs {
    my ($self, $user) = @_;
    my $www = WWW::Mechanize->new();
    my $contriburl = $www->get("http://ftb.gamepedia.com/api.php?action=query&list=users&ususers=$user&usprop=editcount&format=json") or die "Unable to get url.\n";
    my $decodecontribs = $contriburl->decoded_content();
    if ($decodecontribs =~ m{\"missing\"} or $decodecontribs =~ m{\"invalid\"}) {
        return 0;
    } else {
        my @contribs = $decodecontribs =~ m{\"editcount\":(.*?)\}};
        my $contribs = SatanicBot::Utils->separate_by_commas($contribs[0]);
        return $contribs;
    }
}

sub get_registration_date {
    my ($self, $user) = @_;
    my $www = WWW::Mechanize->new();
    my $registerurl = $www->get("http://ftb.gamepedia.com/api.php?action=query&list=users&ususers=$user&usprop=registration&format=json") or die "Unable to get url.\n";
    my $decodereg = $registerurl->decoded_content();
    if ($decodereg =~ m{\"missing\"} or $decodereg =~ m{\"invalid\"}) {
        return 0;
    }
    my @register = $decodereg =~ m{\"registration\":\"(.*?)T};
    return $register[0];
}
1;
