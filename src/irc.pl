#!/usr/bin/perl -w
use warnings;
use strict;

package SatanicBot;
use base qw(Bot::BasicBot);
use POE qw(Component::IRC);

my $bot = Bot::BasicBot->new(
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
  if ($message->{body} eq '!quit'){
    $bot->shutdown($bot->quit_message('Someone killed me!!'));
  }
  if ($message->{body} eq '!abbrv'){
    $self->say($message->{channel}, $message->{'Bitch, that code ain\'t even work yet'})
  }
}
