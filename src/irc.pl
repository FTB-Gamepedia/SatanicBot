#!/usr/bin/perl -w
use warnings;
use strict;
use diagnostics;

package SatanicBot;
use base qw(Bot::BasicBot);
use Data::Random qw(:all);
use Geo::Weather;
require 'wiki.pl';

my $chan = '#SatanicSanta';

my $weather = new Geo::Weather;

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
    $self->say(
      channel => $chan,
      body    => ("Abbreviating $words[2] as $words[1]")
    );

    Wiki->login();
    Wiki->edit_gmods();
    Wiki->logout();

    $self->say(
      channel => $chan,
      body    => 'Abbreviation and documentation added.'
    );
    return undef;
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
  our @weatherwords = split(/,/, $weathermsg, 3);
  if ($weatherwords[0] eq '$weather'){
    $weather->get_weather($weatherwords[1], $weatherwords[2]);
    $self->say(
      channel => $chan,
      body    => $weather->report();
    )
  }

  if ($message->{body} eq '$help'){
    $self->say(
      channel => $chan,
      body    => 'Listing commands... quit, abbrv'
    );
    $self->say(
      channel => $chan,
      body    => 'To get info on a specific command, do $help <command>'
    );
  }

  if ($message->{body} eq '$help quit'){
    $self->say(
      channel => $chan,
      body    => 'Used to stop the bot. Takes no args.'
    );
  }

  if ($message->{body} eq '$help abbrv'){
    $self->say(
      channel => $chan,
      body    => 'Used to add abbreviations to the wiki. Required args: <abbreviation> <mod name>'
    );
  }

  if ($message->{body} eq '$help spookyscaryskeletons'){
    $self->say(
      channel => $chan,
      body    => 'Generates a random word from spook.lines, like EMACS. Takes no args.'
    );
  }
}
