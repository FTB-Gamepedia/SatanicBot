#!/usr/bin/perl -w
use warnings;
use strict;
use diagnostics;

package SatanicBot;
use base qw(Bot::BasicBot);
use Data::Random qw(:all);
use Weather::Underground::Forecast;
require 'wiki.pl';

my $chan = '#SatanicSanta';

my $bot = SatanicBot->new(
  server    => 'irc.esper.net',
  port      => '6667',
  channels  => [$chan],

  nick      => 'SatanicBot|dev',
  alt_nicks => ['SatanicButt', 'SatanicBooty'],
  username  => 'SatanicBot',
  name      => 'SatanicSanta\'s IRC bot'
)->run();

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

      Wiki->login();
      Wiki->edit_gmods();
      Wiki->logout();

      $self->say(
        channel => $chan,
        body    => 'Abbreviation and documentation added.'
      );
      return undef;
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
      shuffle  => 1
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
      $self->say(
          channel => $chan,
          body    => 'I understand the words you just said.'
        );
        my $weather = Weather::Underground::Forecast->new(
          location          => $weatherwords[1],
          temperature_units => 'farenheit'
        );

        my $high   = $weather->highs;
        my $low    = $weather->lows;
        my $precip = $weather->precipitation;
        $self->say(
          channel => $chan,
          body    => 'High: ' . $high
        );
        $self->say(
          channel => $chan,
          body    => 'Low: ' . $low
        );
        $self->say(
          channel => $chan,
          body    => 'Chance of precipitation: ' . $precip->[0]
        );
      } else {
        $self->say(
          channel => $chan,
          body    => 'Please provide the required arguments.'
        )
      }
  }

  if ($message->{body} eq '$help'){
    $self->say(
      channel => $chan,
      body    => 'Listing commands... quit, abbrv, spookyscaryskeletons, weather'
    );
  }
}
