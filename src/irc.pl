#!/usr/bin/perl
# Copyright 2014 Eli Foster

use warnings;
use strict;
use diagnostics;

package SatanicBot;
use base qw(Bot::BasicBot);
use Data::Random qw(:all);
use Weather::Underground::Forecast;
use Data::Dumper;
require 'wiki.pm';
require 'wikib.pm';

my $chan = '#FTB-Wiki';

my $bot = SatanicBot->new(
    server    => 'irc.esper.net',
    port      => '6667',
    channels  => [$chan],

    nick      => 'SatanicBot',
    alt_nicks => ['SatanicButt', 'SatanicBooty'],
    username  => 'SatanicBot',
    name      => 'SatanicSanta\'s IRC bot'
);

$bot->run();

#Use this subroutine definition for adding commands.
sub said{
    my ($self, $message) = @_;

    #quit command: no args
    if ($message->{body} eq '$quit'){
        $bot->shutdown();
    }

    #abbrv command: 2 args required: <abbreviation> <mod name>
    my $msg = $message->{body};
    our @words = split(/\s/, $msg, 3);
    if ($words[0] eq '$abbrv'){
        if ($words[1] =~ m/.+/){
            $self->say(
                channel => $chan,
                body    => "Abbreviating $words[2] as $words[1]"
            );

            Wiki::login();
            Wiki::edit_gmods();

            if (!Wiki::edit_gmods()){
                $self->say(
                channel => $chan,
                body    => 'Could not proceed. Abbreviation and/or name already on the list.'
                );

                Wiki::logout();
            }

            if (Wiki::edit_gmods()){
                $self->say(
                    channel => $chan,
                    body    => 'Abbreviation and documentation added.'
                );

                Wiki::logout();
            }
        } else {
            $self->say(
                channel => $chan,
                body    => 'Please provide the required arguments.'
            );
        }
    }

    if ($message->{body} eq '$spookyscaryskeletons'){
        my @random_words = rand_words(
            wordlist => 'spook.lines',
            min      => 10,
            max      => 20
        );

        $self->say(
            channel => $chan,
            body    => @random_words
        );
    }

    my $weathermsg = $message->{body};
    our @weatherwords = split(/\s/, $weathermsg, 2);
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
            channel => $chan,
            body    => 'High today: ' . $high->[0] . ' F'
        );
        $self->say(
            channel => $chan,
            body    => 'Low today: ' . $low->[0] . ' F'
        );
        $self->say(
            channel => $chan,
            body    => 'Chance of precipitation today: ' . $precip->[0] . '%'
        );
    } else {
        $self->say(
            channel => $chan,
            body    => 'Please provide the required arguments.'
        );
        }
    }

    my $uploadmsg = $message->{body};
    our @uploadwords = split(/\s/, $uploadmsg, 3);
    if ($uploadwords[0] eq '$upload'){
        if ($uploadwords[1] =~ m/.+/){
            if ($uploadwords[2] =~ m/.+/){
                $self->say(
                    channel => $chan,
                    body    => 'Sorry, $wgAllowCopyUploads is not enabled on the Wiki yet :('
                );
                #WikiBot->login();
                #WikiBot->upload();
                #WikiBot->logout();

                #$self->say(
                #    channel => $chan,
                #    body    => "Uploaded $uploadwords[2] to the Wiki."
                #);
            } else {
                $self->say(
                    channel => $chan,
                    body    => 'Please provide the required arguments.'
                );
            }
        } else {
            $self->say(
                channel => $chan,
                body    => 'Please provide the required arguments.'
            );
        }
    }


    if ($message->{body} eq '$help'){
        $self->say(
        channel => $chan,
        body    => 'Listing commands... quit, abbrv, spookyscaryskeletons, weather, upload'
    );
    }
}
1;
