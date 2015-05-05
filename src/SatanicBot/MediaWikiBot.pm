# Copyright 2014 Eli Foster

package SatanicBot::MediaWikiBot;
use warnings;
use strict;
use diagnostics;
use MediaWiki::Bot;
use SatanicBot::Bot;
use SatanicBot::Utils;

my $mw = MediaWiki::Bot->new( {
    protocol => 'https',
    host     => 'ftb.gamepedia.com',
    path     => q{/},
    operator => 'TheSatanicSanta',
    debug    => 2
});
my $ERROR = $!;

sub login {
    $ENV {PERL_LWP_SSL_VERIFY_HOSTNAME} = 0; #This is terrible.
    my $www = WWW::Mechanize->new();
    my $ui = $www->get("http://ftb.gamepedia.com/api.php?action=query&meta=userinfo&format=json");
    my $decode = $ui->decoded_content();
    if ($decode !~ m/\"id\"\:0/) {
        return 1;
    } else {
        my @secure = SatanicBot::Utils->get_secure_contents();
        $mw->login( {
            username => $secure[0],
            password => $secure[1]
        }) or die "Login failed! $mw->{error}->{code}: $mw->{error}->{details}";
        return 1;
    }
}

sub upload {
    my ($self, $url, $title) = @_;
    $mw->upload_from_url( {
        url     => $url,
        title   => $title
    }) or return $mw->{error}->{code} . ':' . $mw->{error}->{details};
    return 1;
}

sub logout {
    $mw->logout();
    return 1;
}
1;
