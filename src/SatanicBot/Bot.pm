# Copyright 2014 Eli Foster

use warnings;
use strict;
use diagnostics;

package SatanicBot::Bot;
use base qw(Bot::BasicBot);
use Data::Random qw(:all);
use Weather::Underground::Forecast;
#use Data::Dumper;
use SatanicBot::Wiki;
use SatanicBot::WikiButt;
use LWP::Simple;
use WWW::Mechanize;

#Use this subroutine definition for adding commands.
sub said{
    my ($self, $message) = @_;

    #quit command: no args
    if ($message->{body} eq '$quit'){
        if ($message->{who} eq 'SatanicSanta'){
            $self->say(
                channel => $message->{channel},
                body    => 'I don\'t love you anymore'
            );
            $self->shutdown();
        } else {
            $self->say(
                channel => $message->{channel},
                body    => "$message->{who}: Fuck you, bitch ass."
            );
        }
    }

    #abbrv command: 2 args required: <abbreviation> <mod name>
    my $msg = $message->{body};
    my @words = split(/\s/, $msg, 3);
    if ($words[0] eq '$abbrv'){
        if ($words[1] =~ m/.+/){
            $self->say(
                channel => $message->{channel},
                body    => "Abbreviating $words[2] as $words[1]"
            );

            SatanicBot::Wiki->login();
            SatanicBot::Wiki->edit_gmods(@words[1,2]);
            SatanicBot::Wiki->logout();

            $self->say(
                channel => $message->{channel},
                body    => 'Abbreviation and documentation probably added. Return values are fucked, which then fucks the message code.'
            );
            #if (!SatanicBot::Wiki->edit_gmods(@words[1,2])) {
            #    $self->say(
            #        channel => $message->{channel},
            #        body    => 'Could not proceed. Abbreviation and/or name already on the list.'
            #    );
            #}
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Please provide the required arguments.'
            );
        }
    }

    if ($message->{body} eq '$spookyscaryskeletons'){
        my @random_words = rand_words(
            wordlist => 'info/spook.lines',
            min      => 10,
            max      => 20
        );

        $self->say(
            channel => $message->{channel},
            body    => @random_words
        );

        #my $dump = Data::Dumper->new([$random_words[0]]);
        #$self->say(
        #    channel => $message->{channel},
        #    body    => $dump
        #);
    }

    my $weathermsg = $message->{body};
    my @weatherwords = split(/\s/, $weathermsg, 2);
    if ($weatherwords[0] eq '$weather'){
        if ($weatherwords[1] =~ m/.+/){
            my $weather = Weather::Underground::Forecast->new(
                location => $weatherwords[1]
        );

        my $high   = $weather->highs;
        my $low    = $weather->lows;
        my $precip = $weather->precipitation;
        #my $dump = Data::Dumper->new([$high]);
        $self->say(
            channel => $message->{channel},
            body    => 'High today: ' . $high->[0] . ' F'
        );
        $self->say(
            channel => $message->{channel},
            body    => 'Low today: ' . $low->[0] . ' F'
        );
        $self->say(
            channel => $message->{channel},
            body    => 'Chance of precipitation today: ' . $precip->[0] . '%'
        );
    } else {
        $self->say(
            channel => $message->{channel},
            body    => 'Please provide the required arguments.'
        );
        }
    }

    #if the command does not work when the API gets enabled, do what you did with $abbrv
    my $uploadmsg = $message->{body};
    our @uploadwords = split(/\s/, $uploadmsg, 3);
    if ($uploadwords[0] eq '$upload'){
        if ($uploadwords[1] =~ m/.+/){
            if ($uploadwords[2] =~ m/.+/){
                #$self->say(
                #    channel => $message->{channel},
                #    body    => 'Sorry, $wgAllowCopyUploads is not enabled on the Wiki yet :('
                #);
                SatanicBot::WikiButt->login();
                SatanicBot::WikiButt->upload();
                SatanicBot::WikiButt->logout();

                $self->say(
                    channel => $message->{channel},
                    body    => "Uploaded $uploadwords[2] to the Wiki."
                );
            } else {
                $self->say(
                    channel => $message->{channel},
                    body    => 'Please provide the required arguments.'
                );
            }
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Please provide the required arguments.'
            );
        }
    }

    my $osrcmessage = $message->{body};
    my @osrcwords = split(/\s/, $osrcmessage, 2);
    if ($osrcwords[0] eq '$osrc'){
        my $url = "https://osrc.dfm.io/$osrcwords[1]";
        if (head($url)){
            $self->say(
                channel => $message->{channel},
                body    => $url
            );
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Does not exist.'
            );
        }
    }

    if ($message->{body} eq '$src'){
        $self->say(
            channel => $message->{channel},
            body    => 'https://github.com/satanicsanta/SatanicBot'
        );
    }

    #This does not currently work. Please do not use it.
    my $contribmsg = $message->{body};
    my @contribwords = split(/\s/, $contribmsg, 2);
    if ($contribwords[0] eq '$contribs'){
        if ($contribwords[1] =~ m/.+/){

            my $www = WWW::Mechanize->new();
            my $stuff = $www->get("http://ftb.gamepedia.com/api.php?action=query&list=users&ususers=$contribwords[1]&usprop=editcount&format=json") or die "Unable to get url.\n";
            my $decode = $stuff->decoded_content();
            my @contribs = $decode =~ m{\"editcount\":(.*?)\}};

            if ($decode =~ m{\"missing\"}){
                $self->say(
                    channel => $message->{channel},
                    body    => 'Please enter a valid username.'
                );
            } else {
                $self->say(
                    channel => $message->{channel},
                    body    => "$contribwords[1] has made $contribs[0] contributions to the wiki."
                );
            }
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Please provide a username.'
            );
        }
    }

    if ($message->{body} eq '$help'){
        $self->say(
            channel => $message->{channel},
            body    => 'Listing commands... quit, abbrv, spookyscaryskeletons, weather, upload, osrc, src, contribs'
        );
    }
}
1;
