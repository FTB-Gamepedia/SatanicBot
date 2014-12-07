#!/usr/bin/perl -w
use warnings;
use strict;
use diagnostics;

package SatanicBot;
use base qw(Bot::BasicBot);
require 'wiki.pl';

my $bot = SatanicBot->new(
  server    => 'irc.esper.net',
  port      => '6667',
  channels  => ['#SatanicSanta'],

  nick      => 'SatanicBot',
  alt_nicks => ['SatanicButt', 'SatanicBooty'],
  username  => 'SatanicBot',
  name      => 'SatanicSanta\'s IRC bot'
)->run();


#Use this subroutine definition for adding commands.
sub said{
  my ($self, $message) = @_;

  #This command is used to stop the bot.
  if ($message->{body} eq '!quit'){
    $bot->shutdown();
  }

  #This command edits User:TheSatanicSanta/Template:G/Mods and /doc
  if ($message->{body} eq '!abbrv'){
    Wiki->login();
    Wiki->edit_gmods();
    $self->say(
      channel => '#SatanicSanta',
      body    => 'Abbreviation and documentation added at '.  ', ' .  '.'
    );
    return undef;
  }
}
