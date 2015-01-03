# Copyright 2014 Eli Foster

use warnings;
use strict;
use diagnostics;

package SatanicBot::Bot;
use base qw(Bot::BasicBot);
use Data::Random qw(:all);
use Weather::Underground;
#use Data::Dumper;
use SatanicBot::Wiki;
use SatanicBot::WikiButt;
use LWP::Simple;
use WWW::Mechanize;
use Math::Symbolic;
use Date::Parse;

#Use this subroutine definition for adding commands.
sub said{
    my ($self, $message) = @_;
    my $channel = $message->{channel};
    my $host = $message->{raw_nick};
    my $msg = $message->{body};
    my $user = $message->{who};

    #quit command: no args. Only those with the nickname SatanicSanta can do it.
    if ($msg eq '$quit'){
        if ($host =~ m/SatanicSa\@/){
            $self->say(
                channel => $channel,
                body    => 'I don\'t love you anymore'
            );
            $self->shutdown();
            exit;
        } else {
            $self->say(
                channel => $channel,
                body    => "$user: Fuck you, bitch ass."
            );
        }
    }

    #Adds the <first arg abbreviation> to the G:Mods and doc as <second arg mod name>
    if ($msg =~ m/^\$abbrv(?: )/){
        my @abbrvwords = split(/\s/, $msg, 3);
        if ($abbrvwords[1] =~ m/.+/ and $abbrvwords[2] =~ m/.+/){
            if ($host =~ m/SatanicSa\@75/ or $host =~ m/retep998\@pool/ or $host =~ m/webchat\@81.168.2.162/ or $host =~ m/Wolfman12\@CPE/){
                $self->say(
                    channel => $channel,
                    body    => "Abbreviating $abbrvwords[2] as $abbrvwords[1]"
                );

                SatanicBot::Wiki->login();
                SatanicBot::Wiki->edit_gmods(@abbrvwords[1,2]);

                if ($SatanicBot::Wiki::check eq 'false') {
                    $self->say(
                        channel => $channel,
                        body    => 'Could not proceed. Abbreviation and/or name already on the list.'
                    );
                } elsif ($SatanicBot::Wiki::check eq 'true'){
                    $self->say(
                        channel => $channel,
                        body    => 'Success!'
                    );
                }
            } else {
                $self->say(
                    channel => $channel,
                    body    => "Blame $user."
                );
            }
        } else {
            $self->say(
                channel => $channel,
                body    => 'Please provide the required arguments.'
            );
        }
    }

    if ($msg eq '$spookyscaryskeletons'){
        my @random_words = rand_words(
            wordlist => 'info/spook.txt',
            min      => 10,
            max      => 20 #for whatever reason, this does not actually work. It only outputs one word. See issue tracker.
        );

        $self->say(
            channel => $channel,
            body    => @random_words
        );

        #my $dump = Data::Dumper->new([$random_words[0]]);
        #$self->say(
        #    channel => $channel,
        #    body    => $dump
        #);
    }

    #Outputs the weather for the <first arg location>.
    if ($msg =~ m/^\$weather(?: )/){
        if ($msg =~ m/\$weather f(?: )/ or $msg =~ m/\$weather F(?: )/){
            my @weatherwords = split(/\s/, $msg, 3);
            if ($weatherwords[2] =~ m/[a-zA-Z\d,]/){
                my $weather = Weather::Underground->new(
                    place => $weatherwords[2]
                );

                my $forecast = $weather->getweather();

                if (exists $forecast->[0]->{place}){
                    $self->say(
                        channel => $channel,
                        body    => "$forecast->[0]->{place}: $forecast->[0]->{conditions} || Temperature: $forecast->[0]->{fahrenheit} F || Humidity: $forecast->[0]->{humidity}% || Last updated: $forecast->[0]->{updated}"
                    );
                } else {
                    $self->say(
                        channel => $channel,
                        body    => "\'$weatherwords[2]\' is not a valid place."
                    );
                }
            } else {
                $self->say(
                    channel => $channel,
                    body    => 'Please provide the required arguments.'
                );
            }
        } elsif ($msg =~ m/\$weather c(?: )/ or $msg =~ m/\$weather C(?: )/){
            my @weatherwords = split(/\s/, $msg, 3);
            if ($weatherwords[2] =~ m/[a-zA-Z\d,]/){
                my $weather = Weather::Underground->new(
                    place => $weatherwords[2]
                );

                my $forecast = $weather->getweather();

                if (exists $forecast->[0]->{place}){
                    $self->say(
                        channel => $channel,
                        body    => "$forecast->[0]->{place}: $forecast->[0]->{conditions} || Temperature: $forecast->[0]->{celsius} C || Humidity: $forecast->[0]->{humidity}% || Last updated: $forecast->[0]->{updated}"
                    );
                } else {
                    $self->say(
                        channel => $channel,
                        body    => "\'$weatherwords[2]\' is not a valid place."
                    );
                }
            } else {
                $self->say(
                    channel => $channel,
                    body    => 'Please provide the required arguments.'
                );
            }
        } else {
            my @weatherwords = split(/\s/, $msg, 2);
            if ($weatherwords[1] =~ m/[a-zA-Z\d,]/){
                my $weather = Weather::Underground->new(
                place => $weatherwords[1]
                );

                my $forecast = $weather->getweather();

                if (exists $forecast->[0]->{place}){
                    $self->say(
                        channel => $channel,
                        body    => "$forecast->[0]->{place}: $forecast->[0]->{conditions} || Temperature: $forecast->[0]->{fahrenheit} F || Humidity: $forecast->[0]->{humidity}% || Last updated: $forecast->[0]->{updated}"
                    );
                } else {
                    $self->say(
                        channel => $channel,
                        body    => "\'$weatherwords[1]\' is not a valid place."
                    );
                }
            } else {
                $self->say(
                    channel => $channel,
                    body    => 'Please provide the required arguments.'
                );
            }
        }
    }

    #if the command does not work when the API gets enabled, do what you did with $abbrv
    #It does not work yet. We still need $wgAllowCopyUploads to be enabled.
    #Uploads the <first arg image> to the wiki as <second arg name>.
    if ($msg =~ m/^\$upload(?: )/){
        our @uploadwords = split(/\s/, $msg, 3);
        if ($uploadwords[1] =~ m/.+/){
            if ($uploadwords[2] =~ m/.+/){
                $self->say(
                    channel => $channel,
                    body    => 'Sorry, $wgAllowCopyUploads is not enabled on the Wiki yet :('
                );
                #if ($host =~ m/75-164-196-89.ptld.qwest.net/){
                    #SatanicBot::WikiButt->login();
                    #SatanicBot::WikiButt->upload();
                    #SatanicBot::WikiButt->logout();

                    #$self->say(
                    #    channel => $channel,
                    #    body    => "Uploaded $uploadwords[2] to the Wiki."
                    #);
                #} else {
                #    $self->say(
                #        channel => $channel,
                #        body    => 'You are not good enough.'
                #    );
                #}
            } else {
                $self->say(
                    channel => $channel,
                    body    => 'Please provide the required arguments.'
                );
            }
        } else {
            $self->say(
                channel => $channel,
                body    => 'Please provide the required arguments.'
            );
        }
    }

    #Outputs the open source report card link for the first argument username. Eventually I should actually do JSON parsing for this.
    if ($msg =~ m/^\$osrc(?: )/){
        my @osrcwords = split(/\s/, $msg, 2);
        my $url = "https://osrc.dfm.io/$osrcwords[1]";
        if (head($url)){
            $self->say(
                channel => $channel,
                body    => $url
            );
        } else {
            $self->say(
                channel => $channel,
                body    => 'Does not exist.'
            );
        }
    }

    #Outputs the link to this bot's source code.
    if ($msg eq '$src'){
        $self->say(
            channel => $channel,
            body    => 'https://github.com/satanicsanta/SatanicBot'
        );
    }

    #Outputs how many contributions the user has made to the wiki.
    #Consider using a JSON parser instead of regular expression.
    if ($msg =~ m/^\$contribs(?: )/){
        my @contribwords = split(/\s/, $msg, 2);
        if ($contribwords[1] =~ m/.+/){
            my $www = WWW::Mechanize->new();
            my $contriburl = $www->get("http://ftb.gamepedia.com/api.php?action=query&list=users&ususers=$contribwords[1]&usprop=editcount&format=json") or die "Unable to get url.\n";
            my $decodecontribs = $contriburl->decoded_content();
            my @contribs = $decodecontribs =~ m{\"editcount\":(.*?)\}};

            my $registerurl = $www->get("http://ftb.gamepedia.com/api.php?action=query&list=users&ususers=$contribwords[1]&usprop=registration&format=json") or die "Unable to get url.\n";
            my $decodereg = $registerurl->decoded_content();
            my @register = $decodereg =~ m{\"registration\":\"(.*?)T};

            if ($decodecontribs =~ m{\"missing\"}){
                $self->say(
                    channel => $channel,
                    body    => 'Please enter a valid username.'
                );
            } elsif ($decodecontribs =~ m{\"invalid\"}) {
                $self->say(
                    channel => $channel,
                    body    => 'Sorry, but IPs are not compatible.'
                );
            } else {
                my $contribs = reverse $contribs[0];
                $contribs =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
                my $num_contribs = reverse $contribs;

                if ($contribs[0] eq '1'){
                    $self->say(
                        channel => $channel,
                        body    => "$contribwords[1] has made 1 contribution to the wiki and registered on $register[0]."
                    );
                } elsif ($contribwords[1] eq 'SatanicBot' or $contribwords[1] eq 'satanicBot') {
                    $self->say(
                        channel => $channel,
                        body    => "I have made $num_contribs contributions to the wiki and registered on $register[0]."
                    );
                } elsif ($contribwords[1] eq 'TheSatanicSanta' or $contribwords[1] eq 'theSatanicSanta'){
                    $self->say(
                        channel => $channel,
                        body    => "The second hottest babe in the channel has made $num_contribs contributions to the wiki and registered on $register[0]."
                    );
                } elsif ($contribwords[1] eq 'Retep998' or $contribwords[1] eq 'retep998'){
                    $self->say(
                        channel => $channel,
                        body    => "The hottest babe in the channel has made $num_contribs contributions to the wiki and registered on $register[0]."
                    );
                } elsif ($contribwords[1] eq 'PonyButt' or $contribwords[1] eq 'ponyButt'){
                    $self->say(
                        channel => $channel,
                        body    => "Some bitch ass nigga has made $num_contribs contributions to the wiki and registered on $register[0]."
                    );
                } else {
                    $self->say(
                        channel => $channel,
                        body    => "$contribwords[1] has made $num_contribs contributions to the wiki and registered on $register[0]."
                    );
                }
            }
        } else {
            $self->say(
                channel => $channel,
                body    => 'Please provide a username.'
            );
        }
    }

    #Outputs a random sentence from 8ball.txt.
    if ($msg eq '$8ball'){
        my $file = 'info/8ball.txt';
        open my $fh, '<', $file or die "Could not open '$file' $!\n";
        my @lines = <$fh>;
        close $fh;
        chomp @lines;
        my $num = int(rand(35));
        $self->say(
            channel => $channel,
            body    => $lines[$num]
        );
    }

    #50/50 chance of outputting heads or tails.
    if ($msg eq '$flip'){
        my $coin = int(rand(2));
        if ($coin eq 1){
            $self->say(
                channel => $channel,
                body    => 'Heads!'
            );
        } else {
            $self->say(
                channel => $channel,
                body    => 'Tails!'
            );
        }
    }

    #Outputs a random quote from ircquotes.txt.
    if ($msg eq '$randquote'){
        my $file = 'info/ircquotes.txt';
        open my $fh, '<', $file or die "Could not open $file $!\n";
        my @lines = <$fh>;
        close $fh;
        chomp @lines;
        my $quote = int(rand(31));
        $self->say(
            channel => $channel,
            body    => $lines[$quote]
        );
    }

    #Wiki statistics.
    #Consider using a real JSON parser rather than regular expression.
    if ($msg =~ m/^\$stats/){
        if ($msg =~ m/^\$stats(?: )/){
            my @statwords = split(/\s/, $msg, 2);
            my $www = WWW::Mechanize->new();
            my $stuff = $www->get("http://ftb.gamepedia.com/api.php?action=query&meta=siteinfo&siprop=statistics&format=json") or die "Unable to get url.\n";
            my $decode = $stuff->decoded_content();

            if ($statwords[1] eq 'pages'){
                my @pages = $decode =~ m{\"pages\":(.*?),};
                $self->say(
                    channel => $channel,
                    body    => "The wiki has $pages[0] pages."
                );
            }
            if ($statwords[1] eq 'articles'){
                my @articulos = $decode =~ m{\"articles\":(.*?),};
                $self->say(
                    channel => $channel,
                    body    => "The wiki has $articulos[0] articles."
                );
            }
            if ($statwords[1] eq 'edits'){
                my @edits = $decode =~ m{\"edits\":(.*?),};
                $self->say(
                    channel => $channel,
                    body    => "The wiki has $edits[0] edits."
                );
            }
            if ($statwords[1] eq 'images'){
                my @images = $decode =~ m{\"images\":(.*?),};
                $self->say(
                    channel => $channel,
                    body    => "The wiki has $images[0] images."
                );
            }
            if ($statwords[1] eq 'users'){
                my @users = $decode =~ m{\"users\":(.*?),};
                $self->say(
                    channel => $channel,
                    body    => "The wiki has $users[0] users."
                );
            }
            if ($statwords[1] eq 'active users'){
                my @activeusers = $decode =~ m{\"activeusers\":(.*?),};
                $self->say(
                    channel => $channel,
                    body    => "The wiki has $activeusers[0] active users."
                );
            }
            if ($statwords[1] eq 'admins'){
                my @admins = $decode =~ m{\"admins\":(.*?),};
                $self->say(
                    channel => $channel,
                    body    => "The wiki has $admins[0] admins."
                );
            }
        } elsif ($msg eq '$stats'){
            my @statwords = split(/\s/, $msg, 2);
            my $www = WWW::Mechanize->new();
            my $stuff = $www->get("http://ftb.gamepedia.com/api.php?action=query&meta=siteinfo&siprop=statistics&format=json") or die "Unable to get url.\n";
            my $decode = $stuff->decoded_content();
            my @pages = $decode =~ m{\"pages\":(.*?),};
            my @articulos = $decode =~ m{\"articles\":(.*?),};
            my @edits = $decode =~ m{\"edits\":(.*?),};
            my @images = $decode =~ m{\"images\":(.*?),};
            my @users = $decode =~ m{\"users\":(.*?),};
            my @activeusers = $decode =~ m{\"activeusers\":(.*?),};
            my @admins = $decode =~ m{\"admins\":(.*?),};
            $self->say(
                channel => $channel,
                body    => "$pages[0] pages || $articulos[0] articles || $edits[0] edits || $images[0] images || $users[0] users || $activeusers[0] active users || $admins[0] admins"
            );
        }
    }

    if ($msg =~ m/^\$calc(?: )/){
        my @calcwords = split(/\s/, $msg, 2);
        if ($calcwords[1] =~ m/\d/){
            my $out = eval($calcwords[1]);
            $self->say(
                channel => $channel,
                body    => "$calcwords[1] = $out"
            );
        } elsif ($calcwords[1] =~ m/\D/){
            my $algebra = Math::Symbolic->parse_from_string($calcwords[1]);
            $self->say(
                channel => $channel,
                body    => "$calcwords[1] = $algebra"
            );
        } else {
            $self->say(
                channel => $channel,
                body    => 'Please provide an equation.'
            );
        }
    }

#    my $minormodsmsg = $msg;
#    my @minormodswords = split(/\s/, $minormodsmsg, 2);
#    if ($minormodswords[0] eq '$addminor'){
#        if ($minormodswords[1] =~ m/.+/){
#            $self->say(
#                channel => $channel,
#                body    => "Adding $minormodswords[1] to the Minor Mods list."
#            );
#
#            SatanicBot::Wiki->login();
#            SatanicBot::Wiki->edit_minor($minormodswords[1]);
#
#            if ($SatanicBot::Wiki::minor eq 'false') {
#                $self->say(
#                    channel => $channel,
#                    body    => 'Could not proceed. Mod already on the list.'
#                );
#            } elsif ($SatanicBot::Wiki::minor eq 'true'){
#                $self->say(
#                    channel => $channel,
#                    body    => 'Success!'
#                );
#            }
#        } else {
#            $self->say(
#                channel => $channel,
#                body    => 'Please provide the required arguments.'
#            );
#        }
#    }

    if ($msg =~ m/^\$randnum/){
        my @randwords = split(/\s/, $msg, 2);
        if ($randwords[1] =~ m/\d/){
            $self->say(
                channel => $channel,
                body    => int(rand($randwords[1] + 1))
            );
        } else {
            $self->say(
                channel => $channel,
                body    => 'No argument provided. Using 100... ' . int(rand(101))
            );
        }
    }

    if ($msg =~ m/^\$game/){
        my @gamewords = split(/\s/, $msg, 3);
        if ($gamewords[1] eq 'int'){
            my $num = int(rand(101));
            if ($gamewords[2] eq $num){
                $self->say(
                    channel => $channel,
                    body    => "Correct! The answer was $num"
                );
            } else {
                $self->say(
                    channel => $channel,
                    body    => "Wrong! The answer was $num"
                );
            }
        } elsif ($gamewords[1] eq 'float'){
            my $num = rand(10);
            if ($gamewords[2] eq $num){
                $self->say(
                    channel => $channel,
                    body    => "Correct! The answer was $num"
                );
            } else {
                $self->say(
                    channel => $channel,
                    body    => "Wrong! The answer was $num"
                );
            }
        } else {
            $self->say(
                channel => $channel,
                body    => 'Please provide the required arguments.'
            );
        }
    }

    #Provides the user with a command list.
    if ($msg =~ m/^\$help/){
        my @helpwords = split(/\s/, $msg, 2);
        if ($helpwords[1] eq 'quit'){
            $self->say(
                channel => $channel,
                body    => 'Stops the bot. No args.'
            );
        }
        if ($helpwords[1] eq 'abbrv'){
            $self->say(
                channel => $channel,
                body    => 'Abbreivates a mod for the tilesheet extension. 2 Args: <abbreviation> <mod name>'
            );
        }
        if ($helpwords[1] eq 'spookyscaryskeletons'){
            $self->say(
                channel => $channel,
                body    => 'Very spooky. No args. This command is broken.'
            );
        }
        if ($helpwords[1] eq 'weather'){
            $self->say(
                channel => $channel,
                body    => 'Provides weather information for the given place. 1 required arg, 1 optional arg: <(optional) f or c> <place>'
            );
        }
        if ($helpwords[1] eq 'upload'){
            $self->say(
                channel => $channel,
                body    => 'Uploads an image to the wiki. 2 args: <file link> <file name>'
            );
        }
        if ($helpwords[1] eq 'osrc'){
            $self->say(
                channel => $channel,
                body    => 'Links the open source report card for the user. 1 optional arg: <username>'
            );
        }
        if ($helpwords[1] eq 'src'){
            $self->say(
                channel => $channel,
                body    => 'Links the source code for this bot. No args.'
            );
        }
        if ($helpwords[1] eq 'contribs'){
            $self->say(
                channel => $channel,
                body    => 'Provides some user information including num of contribs to the wiki and registration date. 1 arg: <username>'
            );
        }
        if ($helpwords[1] eq 'flip'){
            $self->say(
                channel => $channel,
                body    => 'Heads or tails! No args'
            );
        }
        if ($helpwords[1] eq '8ball'){
            $self->say(
                channel => $channel,
                body    => 'Determines your fortune. No args'
            );
        }
        if ($helpwords[1] eq 'randquote'){
            $self->say(
                channel => $channel,
                body    => 'Gives a random quote from the #FTB-Wiki IRC channel. No args'
            );
        }
        if ($helpwords[1] eq 'stats'){
            $self->say(
                channel => $channel,
                body    => 'Gives wiki stats. 1 optional arg: <pages or articles or edits or images or users or activeusers or admins>'
            );
        }
        if ($helpwords[1] eq 'calc'){
            $self->say(
                channel => $channel,
                body    => 'Derpy calculator. Takes an equation. This performs eval; if it doesn\'t work blame eval'
            );
        }
        if ($helpwords[1] eq 'randnum'){
            $self->say(
                channel => $channel,
                body    => 'Generates a random number. 1 optional arg, if not provided it will assume 0-100: <max num>'
            );
        }
        if ($helpwords[1] eq 'game'){
            $self->say(
                channel => $channel,
                body    => 'Number guessing game. 2 args: <int or float> <guess>'
            );
        } elsif ($helpwords[1] !~ m/.+/) {
            $self->say(
                channel => $channel,
                body    => 'Listing commands... quit, abbrv, spookyscaryskeletons, weather, upload, osrc, src, contribs, flip, 8ball, randquote, stats, calc, randnum, game'
            );
        }
    }
}
1;
