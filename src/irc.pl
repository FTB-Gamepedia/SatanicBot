#!/usr/bin/perl -w
use warnings;
use strict;
use diagnostics;

package SatanicBot;
use base qw(Bot::BasicBot);

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

  #This command does not do anything YET. See issues.
  if ($message->{body} eq '!abbrv'){
    $self->say(
      channel => '#SatanicSanta',
      body    => 'Bitch, that code ain\'t even work yet'
    );
    return undef;
  }
}
