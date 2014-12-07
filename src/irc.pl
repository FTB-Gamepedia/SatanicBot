#!/usr/bin/perl -w
use warnings;
use strict;
use diagnostics;

package SatanicBot;
use base qw(Bot::BasicBot);
require 'wiki.pl';

my $chan = '#FTB-Wiki';

my $bot = SatanicBot->new(
  server    => 'irc.esper.net',
  port      => '6667',
  channels  => [$chan],

  nick      => 'SatanicBot',
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

  if ($message->{body} eq '$help quit'){
    $self->say(
      channel => $chan,
      body    => 'Used to add abbreviations to the wiki. Required args: <abbreviation> <mod name>'
    );
  }
}
