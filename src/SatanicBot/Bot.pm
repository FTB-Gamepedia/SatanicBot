# Copyright 2014 Eli Foster

use warnings;
use strict;
use diagnostics;

package SatanicBot::Bot;
use base qw(Bot::BasicBot);
use Data::Random qw(:all);
use Weather::Underground;
use Weather::Underground::Forecast;
#use Data::Dumper;
use SatanicBot::Wiki;
use SatanicBot::WikiButt;
use LWP::Simple;
use WWW::Mechanize;
use Math::Symbolic;

#Use this subroutine definition for adding commands.
sub said{
    my ($self, $message) = @_;

    #quit command: no args. Only those with the nickname SatanicSanta can do it.
    if ($message->{body} eq '$quit'){
        if ($message->{raw_nick} =~ m/75-164-196-89.ptld.qwest.net/){
            $self->say(
                channel => $message->{channel},
                body    => 'I don\'t love you anymore'
            );
            $self->shutdown();
            exit;
        } else {
            $self->say(
                channel => $message->{channel},
                body    => "$message->{who}: Fuck you, bitch ass."
            );
        }
    }

    #Adds the <first arg abbreviation> to the G:Mods and doc as <second arg mod name>
    my $msg = $message->{body};
    my @words = split(/\s/, $msg, 3);
    if ($words[0] eq '$abbrv'){
        if ($words[1] =~ m/.+/){
            if ($message->{raw_nick} =~ m/SatanicSa\@75/ or $message->{raw_nick} =~ m/retep998\@pool/ or $message->{raw_nick} =~ m/webchat\@81.168.2.162/){
                $self->say(
                    channel => $message->{channel},
                    body    => "Abbreviating $words[2] as $words[1]"
                );

                SatanicBot::Wiki->login();
                SatanicBot::Wiki->edit_gmods(@words[1,2]);

                if ($SatanicBot::Wiki::check eq 'false') {
                    $self->say(
                        channel => $message->{channel},
                        body    => 'Could not proceed. Abbreviation and/or name already on the list.'
                    );
                } elsif ($SatanicBot::Wiki::check eq 'true'){
                    $self->say(
                        channel => $message->{channel},
                        body    => 'Success!'
                    );
                }
            } else {
                $self->say(
                    channel => $message->{channel},
                    body    => "Blame $message->{who}."
                );
            }
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Please provide the required arguments.'
            );
        }
    }

    if ($message->{body} eq '$spookyscaryskeletons'){
        my @random_words = rand_words(
            wordlist => 'info/spook.txt',
            min      => 10,
            max      => 20 #for whatever reason, this does not actually work. It only outputs one word. See issue tracker.
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

    #Outputs the weather for the <first arg location>.
    my $weathermsg = $message->{body};
    my @weatherwords = split(/\s/, $weathermsg, 2);
    if ($weatherwords[0] eq '$weather'){
        if ($weatherwords[1] =~ m/.+/){
            my $weather = Weather::Underground->new(
                place => $weatherwords[1]
            );

            my $urmomweather = Weather::Underground::Forecast->new(
                location => $weatherwords[1]
            );

            my $forecast  = $weather->getweather();
            my $urmomhigh = $urmomweather->highs;
            my $urmomlow  = $urmomweather->lows;
            my $momprecip = $urmomweather->precipitation;

            if (exists $forecast->[0]->{conditions}){
                $self->say(
                    channel => $message->{channel},
                    body    => "$forecast->[0]->{conditions} || Precipitation: $momprecip->[0] % chance || Temperature: $forecast->[0]->{fahrenheit} F ($urmomlow->[0] - $urmomhigh->[0] F) || Humidity: $forecast->[0]->{humidity}% || Last updated: $forecast->[0]->{updated}"
                    );
            } else {
                $self->say(
                    channel => $message->{channel},
                    body    => "\'$weatherwords[1]\' is not a valid place."
                );
            }
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Please provide the required arguments.'
            );
        }
    }

    #if the command does not work when the API gets enabled, do what you did with $abbrv
    #It does not work yet. We still need $wgAllowCopyUploads to be enabled.
    #Uploads the <first arg image> to the wiki as <second arg name>.
    my $uploadmsg = $message->{body};
    our @uploadwords = split(/\s/, $uploadmsg, 3);
    if ($uploadwords[0] eq '$upload'){
        if ($uploadwords[1] =~ m/.+/){
            if ($uploadwords[2] =~ m/.+/){
                $self->say(
                    channel => $message->{channel},
                    body    => 'Sorry, $wgAllowCopyUploads is not enabled on the Wiki yet :('
                );
                #if ($message->{raw_nick} =~ m/75-164-196-89.ptld.qwest.net/){
                    #SatanicBot::WikiButt->login();
                    #SatanicBot::WikiButt->upload();
                    #SatanicBot::WikiButt->logout();

                    #$self->say(
                    #    channel => $message->{channel},
                    #    body    => "Uploaded $uploadwords[2] to the Wiki."
                    #);
                #} else {
                #    $self->say(
                #        channel => $message->{channel},
                #        body    => 'You are not good enough.'
                #    );
                #}
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

    #Outputs the open source report card link for the first argument username. Eventually I should actually do JSON parsing for this.
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

    #Outputs the link to this bot's source code.
    if ($message->{body} eq '$src'){
        $self->say(
            channel => $message->{channel},
            body    => 'https://github.com/satanicsanta/SatanicBot'
        );
    }

    #Outputs how many contributions the user has made to the wiki.
    #Consider using a JSON parser instead of regular expression.
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
            } elsif ($decode =~ m{\"invalid\"}) {
                $self->say(
                    channel => $message->{channel},
                    body    => 'Sorry, but IPs are not compatible.'
                );
            } else {
                if ($contribs[0] eq '1'){
                    $self->say(
                        channel => $message->{channel},
                        body    => "$contribwords[1] has made $contribs[0] contribution to the wiki."
                    );
                } elsif ($contribwords[1] eq 'SatanicBot' or $contribwords[1] eq 'satanicBot') {
                    $self->say(
                        channel => $message->{channel},
                        body    => "I have made $contribs[0] contributions to the wiki."
                    );
                } elsif ($contribwords[1] eq 'TheSatanicSanta' or $contribwords[1] eq 'theSatanicSanta'){
                    $self->say(
                        channel => $message->{channel},
                        body    => "The second hottest babe in the channel has made $contribs[0] contributions to the wiki."
                    );
                } elsif ($contribwords[1] eq 'Retep998' or $contribwords[1] eq 'retep998'){
                    $self->say(
                        channel => $message->{channel},
                        body    => "The hottest babe in the channel has made $contribs[0] contributions to the wiki."
                    );
                } elsif ($contribwords[1] eq 'PonyButt' or $contribwords[1] eq 'ponyButt'){
                    $self->say(
                        channel => $message->{channel},
                        body    => "Some bitch ass nigga has made $contribs[0] contributions to the wiki."
                    );
                } else {
                    $self->say(
                        channel => $message->{channel},
                        body    => "$contribwords[1] has made $contribs[0] contributions to the wiki."
                    );
                }
            }
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Please provide a username.'
            );
        }
    }

    #Outputs a random sentence from 8ball.txt.
    if ($message->{body} eq '$8ball'){
        my $file = 'info/8ball.txt';
        open my $fh, '<', $file or die "Could not open '$file' $!\n";
        my @lines = <$fh>;
        close $fh;
        chomp @lines;
        my $num = int(rand(35));
        $self->say(
            channel => $message->{channel},
            body    => $lines[$num]
        );
    }

    #50/50 chance of outputting heads or tails.
    if ($message->{body} eq '$flip'){
        my $coin = int(rand(2));
        if ($coin eq 1){
            $self->say(
                channel => $message->{channel},
                body    => 'Heads!'
            );
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Tails!'
            );
        }
    }

    #Outputs a random quote from ircquotes.txt.
    if ($message->{body} eq '$randquote'){
        my $file = 'info/ircquotes.txt';
        open my $fh, '<', $file or die "Could not open $file $!\n";
        my @lines = <$fh>;
        close $fh;
        chomp @lines;
        my $quote = int(rand(31));
        $self->say(
            channel => $message->{channel},
            body    => $lines[$quote]
        );
    }

    #Wiki statistics.
    #Consider using a real JSON parser rather than regular expression.
    my $statmsg = $message->{body};
    my @statwords = split(/\s/, $statmsg, 2);
    if ($statwords[0] eq '$stats'){

        my $www = WWW::Mechanize->new();
        my $stuff = $www->get("http://ftb.gamepedia.com/api.php?action=query&meta=siteinfo&siprop=statistics&format=json") or die "Unable to get url.\n";
        my $decode = $stuff->decoded_content();

        if ($statwords[1] eq 'all' or $statwords[1] !~ m/.+/){
            my @pages = $decode =~ m{\"pages\":(.*?),};
            my @articulos = $decode =~ m{\"articles\":(.*?),};
            my @edits = $decode =~ m{\"edits\":(.*?),};
            my @images = $decode =~ m{\"images\":(.*?),};
            my @users = $decode =~ m{\"users\":(.*?),};
            my @activeusers = $decode =~ m{\"activeusers\":(.*?),};
            my @admins = $decode =~ m{\"admins\":(.*?),};
            $self->say(
                channel => $message->{channel},
                body    => "$pages[0] pages || $articulos[0] articles || $edits[0] edits || $images[0] images || $users[0] users || $activeusers[0] active users || $admins[0] admins"
            );
        } elsif ($statwords[1] eq 'pages'){
            my @pages = $decode =~ m{\"pages\":(.*?),};
            $self->say(
                channel => $message->{channel},
                body    => "The wiki has $pages[0] pages."
            );
        } elsif ($statwords[1] eq 'articles'){
            my @articulos = $decode =~ m{\"articles\":(.*?),};
            $self->say(
                channel => $message->{channel},
                body    => "The wiki has $articulos[0] articles."
            );
        } elsif ($statwords[1] eq 'edits'){
            my @edits = $decode =~ m{\"edits\":(.*?),};
            $self->say(
                channel => $message->{channel},
                body    => "The wiki has $edits[0] edits."
            );
        } elsif ($statwords[1] eq 'images'){
            my @images = $decode =~ m{\"images\":(.*?),};
            $self->say(
                channel => $message->{channel},
                body    => "The wiki has $images[0] images."
            );
        } elsif ($statwords[1] eq 'users'){
            my @users = $decode =~ m{\"users\":(.*?),};
            $self->say(
                channel => $message->{channel},
                body    => "The wiki has $users[0] users."
            );
        } elsif ($statwords[1] eq 'active users'){
            my @activeusers = $decode =~ m{\"activeusers\":(.*?),};
            $self->say(
                channel => $message->{channel},
                body    => "The wiki has $activeusers[0] active users."
            );
        } elsif ($statwords[1] eq 'admins'){
            my @admins = $decode =~ m{\"admins\":(.*?),};
            $self->say(
                channel => $message->{channel},
                body    => "The wiki has $admins[0] admins."
            );
        }
    }

    my $calcmsg = $message->{body};
    my @calcwords = split(/\s/, $calcmsg, 2);
    if ($calcwords[0] eq '$calc'){
        if ($calcwords[1] =~ m/\d/){
            my $out = eval($calcwords[1]);
            $self->say(
                channel => $message->{channel},
                body    => "$calcwords[1] = $out"
            );
        } elsif ($calcwords[1] =~ m/\D/){
            my $algebra = Math::Symbolic->parse_from_string($calcwords[1]);
            $self->say(
                channel => $message->{channel},
                body    => "$calcwords[1] = $algebra"
            );
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Please provide an equation.'
            );
        }
    }

#    my $minormodsmsg = $message->{body};
#    my @minormodswords = split(/\s/, $minormodsmsg, 2);
#    if ($minormodswords[0] eq '$addminor'){
#        if ($minormodswords[1] =~ m/.+/){
#            $self->say(
#                channel => $message->{channel},
#                body    => "Adding $minormodswords[1] to the Minor Mods list."
#            );
#
#            SatanicBot::Wiki->login();
#            SatanicBot::Wiki->edit_minor($minormodswords[1]);
#
#            if ($SatanicBot::Wiki::minor eq 'false') {
#                $self->say(
#                    channel => $message->{channel},
#                    body    => 'Could not proceed. Mod already on the list.'
#                );
#            } elsif ($SatanicBot::Wiki::minor eq 'true'){
#                $self->say(
#                    channel => $message->{channel},
#                    body    => 'Success!'
#                );
#            }
#        } else {
#            $self->say(
#                channel => $message->{channel},
#                body    => 'Please provide the required arguments.'
#            );
#        }
#    }

    my $randmsg = $message->{body};
    my @randwords = split(/\s/, $randmsg, 2);
    if ($randwords[0] eq '$randnum'){
        if ($randwords[1] =~ m/\d/){
            $self->say(
                channel => $message->{channel},
                body    => int(rand($randwords[1] + 1))
            );
        }
    }

    my $gamemsg = $message->{body};
    my @gamewords = split(/\s/, $gamemsg, 3);
    if ($gamewords[0] eq '$game'){
        if ($gamewords[1] eq 'int'){
            my $num = int(rand(101));
            if ($gamewords[2] eq $num){
                $self->say(
                    channel => $message->{channel},
                    body    => "Correct! The answer was $num"
                );
            } else {
                $self->say(
                    channel => $message->{channel},
                    body    => "Wrong! The answer was $num"
                );
            }
        } elsif ($gamewords[1] eq 'float'){
            my $num = rand(10);
            if ($gamewords[2] eq $num){
                $self->say(
                    channel => $message->{channel},
                    body    => "Correct! The answer was $num"
                );
            } else {
                $self->say(
                    channel => $message->{channel},
                    body    => "Wrong! The answer was $num"
                );
            }
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Please provide the required arguments.'
            );
        }
    }

    #Provides the user with a command list.
    if ($message->{body} eq '$help'){
        $self->say(
            channel => $message->{channel},
            body    => 'Listing commands... quit, abbrv, spookyscaryskeletons, weather, upload, osrc, src, contribs, flip, 8ball, randquote, stats, calc, randnum'
        );
    }
}
1;
