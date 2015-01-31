# Copyright 2014 Eli Foster

package SatanicBot::Bot;
use warnings;
use strict;
use diagnostics;
use base qw(Bot::BasicBot);
use Data::Random;
use Weather::Underground;
use Data::Dumper;
use SatanicBot::MediaWikiAPI;
use SatanicBot::MediaWikiBot;
use LWP::Simple;
use WWW::Mechanize;
use Math::Symbolic;
use Date::Parse;
use File::RandomLine;
use WWW::Twitter;
use SatanicBot::Utils;
use Geo::IP;

#Use this subroutine definition for adding commands.
sub said {
    my ($self, $message) = @_;
    my $channel = $message->{channel};
    my $host = $message->{raw_nick};
    my $msg = $message->{body};
    my $user = $message->{who};
    my $ERROR = $!;
    my $args = 'Please provide the required arguments.';
    my %bot_stuff_hash = (
        ops       => [],
        auth_pass => ''
    );
    my $bot_stuff = \%bot_stuff_hash;
    
    if ($msg =~ m/^\$pass/i) {
        if ($msg !~ m/^\$pass$/i) {
            if ($host =~ m/!~SatanicSa\@c-73/) {
                my @password = split /\s/, $msg, 2;
                $bot_stuff->{auth_pass} = $password[1];
                $self->say(
                    channel => 'msg',
                    who     => $user,
                    body    => "Password set to $bot_stuff->{auth_pass}"
                );
            }
        } else {
            $self->say(
                channel => 'msg',
                who     => $user,
                body    => $args
            );
        }
    }

    if ($msg =~ m/^\$auth/i) {
        if ($msg !~ m/^\$auth$/i) {
            my @authwords = split /\s/, $msg, 2;
            if ($authwords[1] eq $bot_stuff->{ auth_pass }) {
                push @{$bot_stuff->{ops}}, $host;
                $self->say(
                    channel => 'msg',
                    who     => $user,
                    body    => "$user, you are now logged in."
                );
            }
        } else {
            $self->say(
                channel => $channel,
                body    => $args
            );
        }
    }

    foreach my $op (@{$bot_stuff->{ops}}) {
        if ($host eq $op) {
            if ($msg =~ m/^\$quit$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'I don\'t love you anymore' #For some reason this does not get said before it quits in most cases.
                );
                $self->shutdown(); #Consider replacing the message said before it quits with an actual quit message.
                exit 0;
            }

            #Adds the <first arg abbreviation> to the G:Mods and doc as <second arg mod name>
            if ($msg =~ m/^\$abbrv(?: )/i) {
                my @abbrvwords = split /\s/, $msg, 3;
                if ($abbrvwords[1] =~ m/.+/ and $abbrvwords[2] =~ m/.+/) {
                    if ($abbrvwords[1] =~ m/[\p{IsUpper}\d]/) {
                        $self->say(
                            channel => $channel,
                            body    => "Abbreviating \'$abbrvwords[2]\' as \'$abbrvwords[1]\'"
                        );

                        SatanicBot::MediaWikiAPI->login();
                        SatanicBot::MediaWikiAPI->edit_gmods(@abbrvwords[1,2]);

                        if ($SatanicBot::MediaWikiAPI::CHECK eq 'false') {
                            $self->say(
                                channel => $channel,
                                body    => 'Could not proceed. Abbreviation and/or name already on the list.'
                            );
                        } elsif ($SatanicBot::MediaWikiAPI::CHECK eq 'true') {
                            $self->say(
                                channel => $channel,
                                body    => 'Success!'
                            );
                        }
                    } else {
                        $self->say(
                            channel => $channel,
                            body    => 'Abbreviations can only be capital letters and digits.'
                        );
                    }
                } else {
                    $self->say(
                        channel => $channel,
                        body    => $args
                    );
                }
            }

            #Uploads the <first arg image> to the wiki as <second arg name>.
            if ($msg =~ m/^\$upload(?: )/i) {
                our @uploadwords = split /\s/, $msg, 3;
                if ($uploadwords[1] =~ m/.+/) {
                    if ($uploadwords[2] =~ m/.+/) {

                        SatanicBot::MediaWikiBot->login();
                        SatanicBot::MediaWikiBot->upload();
                        SatanicBot::MediaWikiBot->logout();

                        $self->say(
                            channel => $channel,
                            body    => "Uploaded \'$uploadwords[2]\' to the Wiki."
                        );
                    } else {
                        $self->say(
                            channel => $channel,
                            body    => $args
                        );
                    }
                } else {
                    $self->say(
                        channel => $channel,
                        body    => $args
                    );
                }
            }
        }
    }



    if ($msg =~ m/^\$spookyscaryskeletons$/i) {
        my @random_words = Data::Random->rand_words(
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
    if ($msg =~ m/^\$weather(?: )/i) {
        if ($msg =~ m/\$weather f(?: )/i) {
            my @weatherwords = split /\s/, $msg, 3;
            if ($weatherwords[2] =~ m/[\p{IsAlphabetic}\d,]/) {
                my $weather = Weather::Underground->new(
                    place => $weatherwords[2]
                );

                my $forecast = $weather->getweather();

                if (exists $forecast->[0]->{place}) {
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
                    body    => $args
                );
            }
        } elsif ($msg =~ m/\$weather c(?: )/i) {
            my @weatherwords = split /\s/, $msg, 3;
            if ($weatherwords[2] =~ m/[\p{IsAlphabetic}\d,]/) {
                my $weather = Weather::Underground->new(
                    place => $weatherwords[2]
                );

                my $forecast = $weather->getweather();

                if (exists $forecast->[0]->{place}) {
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
                    body    => $args
                );
            }
        } else {
            my @weatherwords = split /\s/, $msg, 2;
            if ($weatherwords[1] =~ m/[\p{IsAlphabetic}\d,]/) {
                my $weather = Weather::Underground->new(
                    place => $weatherwords[1]
                );

                my $forecast = $weather->getweather();

                if (exists $forecast->[0]->{place}) {
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
                    body    => $args
                );
            }
        }
    }
=pod
    if ($msg =~ m/^\$weather$/i) {
        my $ip = $message->{raw_nick};
        $ip =~ s/^[^\@]*\@//;
        my $geoip = Geo::IP->new();
        my $record_by_name = $geoip->record_by_name($ip);
        my $weather = Weather::Underground->new(
            place => $record_by_name->postal_code
        );
        my $forecast = $weather->getweather();

        $self->say(
            channel => $channel,
            body    => "$forecast->[0]->{place}: $forecast->[0]->{conditions} || Temperature: $forecast->[0]->{fahrenheit} F || Humidity: $forecast->[0]->{humidity}% || Last updated: $forecast->[0]->{updated}"
        );
    }
=cut


    #Outputs the open source report card link for the first argument username. Eventually I should actually do JSON parsing for this.
    if ($msg =~ m/^\$osrc(?: )/i) {
        my @osrcwords = split /\s/, $msg, 2;
        my $url = "https://osrc.dfm.io/$osrcwords[1]";
        if (head($url)) {
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
    if ($msg =~ m/^\$src$/i) {
        $self->say(
            channel => $channel,
            body    => 'https://github.com/satanicsanta/SatanicBot'
        );
    }

    #Outputs how many contributions the user has made to the wiki.
    #Consider using a JSON parser instead of regular expression.
    if ($msg =~ m/^\$contribs(?: )/i) {
        my @contribwords = split /\s/, $msg, 2;
        if ($contribwords[1] =~ m/.+/) {
            my $www = WWW::Mechanize->new();
            my $contriburl = $www->get("http://ftb.gamepedia.com/api.php?action=query&list=users&ususers=$contribwords[1]&usprop=editcount&format=json") or die "Unable to get url.\n";
            my $decodecontribs = $contriburl->decoded_content();
            my @contribs = $decodecontribs =~ m{\"editcount\":(.*?)\}};
            my @name = $decodecontribs =~ m{\"name\":\"(.*?)\"};

            my $registerurl = $www->get("http://ftb.gamepedia.com/api.php?action=query&list=users&ususers=$contribwords[1]&usprop=registration&format=json") or die "Unable to get url.\n";
            my $decodereg = $registerurl->decoded_content();
            my @register = $decodereg =~ m{\"registration\":\"(.*?)T};

            if ($decodecontribs =~ m{\"missing\"}) {
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
                my $num_contribs = SatanicBot::Utils->separate_by_commas($contribs[0]);

                if ($contribs[0] eq '1') {
                    $self->say(
                        channel => $channel,
                        body    => "$name[0] has made 1 contribution to the wiki and registered on $register[0]."
                    );
                } elsif ($contribwords[1] eq 'SatanicBot' or $contribwords[1] eq 'satanicBot') {
                    $self->say(
                        channel => $channel,
                        body    => "I have made $num_contribs contributions to the wiki and registered on $register[0]."
                    );
                } elsif ($contribwords[1] eq 'TheSatanicSanta' or $contribwords[1] eq 'theSatanicSanta') {
                    $self->say(
                        channel => $channel,
                        body    => "The second hottest babe in the channel has made $num_contribs contributions to the wiki and registered on $register[0]."
                    );
                } elsif ($contribwords[1] eq 'Retep998' or $contribwords[1] eq 'retep998') {
                    $self->say(
                        channel => $channel,
                        body    => "The hottest babe in the channel has made $num_contribs contributions to the wiki and registered on $register[0]."
                    );
                } elsif ($contribwords[1] eq 'PonyButt' or $contribwords[1] eq 'ponyButt') {
                    $self->say(
                        channel => $channel,
                        body    => "Some bitch ass nigga has made $num_contribs contributions to the wiki and registered on $register[0]."
                    );
                } else {
                    $self->say(
                        channel => $channel,
                        body    => "$name[0] has made $num_contribs contributions to the wiki and registered on $register[0]."
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
    if ($msg =~ m/^\$8ball$/i) {
        my $file = 'info/8ball.txt';
        my $rl = File::RandomLine->new($file);
        my $fortune = $rl->next(1);
        chomp $fortune;
        $self->say(
            channel => $channel,
            body    => $fortune
        );
    }

    #50/50 chance of outputting heads or tails.
    if ($msg =~ m/^\$flip$/i) {
        my $coin = int rand 2;
        if ($coin eq 1) {
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
    if ($msg =~ m/^\$randquote$/i) {
        my $file = 'info/ircquotes.txt';
        my $rl = File::RandomLine->new($file);
        my $quote = $rl->next(1);
        chomp $quote;
        $self->say(
            channel => $channel,
            body    => $quote
        );
    }

    #Wiki statistics.
    #Consider using a real JSON parser rather than regular expression.
    #This could definitely be less verbose. Just not sure how yet.
    if ($msg =~ m/^\$stats/i) {
        if ($msg =~ m/^\$stats(?: )/i) {
            my @statwords = split /\s/, $msg, 2;
            my $www = WWW::Mechanize->new();
            my $stuff = $www->get('http://ftb.gamepedia.com/api.php?action=query&meta=siteinfo&siprop=statistics&format=json') or die "Unable to get url.\n";
            my $decode = $stuff->decoded_content();

            if ($statwords[1] =~ m/^pages$/i) {
                my @pages = $decode =~ m{\"pages\":(.*?),};
                my $num_pages = SatanicBot::Utils->separate_by_commas($pages[0]);

                $self->say(
                    channel => $channel,
                    body    => "The wiki has $num_pages pages."
                );
            }
            if ($statwords[1] =~ m/^articles$/i) {
                my @articulos = $decode =~ m{\"articles\":(.*?),};
                my $num_articles = SatanicBot::Utils->separate_by_commas($articulos[0]);

                $self->say(
                    channel => $channel,
                    body    => "The wiki has $num_articles articles."
                );
            }
            if ($statwords[1] =~ m/^edits$/i) {
                my @edits = $decode =~ m{\"edits\":(.*?),};
                my $num_edits = SatanicBot::Utils->separate_by_commas($edits[0]);

                $self->say(
                    channel => $channel,
                    body    => "The wiki has $num_edits edits."
                );
            }
            if ($statwords[1] =~ m/^images$/i) {
                my @images = $decode =~ m{\"images\":(.*?),};
                my $num_images = SatanicBot::Utils->separate_by_commas($images[0]);

                $self->say(
                    channel => $channel,
                    body    => "The wiki has $num_images images."
                );
            }
            if ($statwords[1] =~ m/^users$/i) {
                my @users = $decode =~ m{\"users\":(.*?),};
                my $num_users = SatanicBot::Utils->separate_by_commas($users[0]);

                $self->say(
                    channel => $channel,
                    body    => "The wiki has $num_users users."
                );
            }
            if ($statwords[1] =~ m/^active users$/i) {
                my @activeusers = $decode =~ m{\"activeusers\":(.*?),};
                my $num_active = SatanicBot::Utils->separate_by_commas($activeusers[0]);
                $self->say(
                    channel => $channel,
                    body    => "The wiki has $num_active active users."
                );
            }
            if ($statwords[1] =~ m/^admins$/i) {
                my @admins = $decode =~ m{\"admins\":(.*?),};
                my $num_admins = SatanicBot::Utils->separate_by_commas($admins[0]);

                $self->say(
                    channel => $channel,
                    body    => "The wiki has $num_admins admins."
                );
            }
        } elsif ($msg =~ m/^\$stats$/i) {
            my @statwords   = split(/\s/, $msg, 2);
            my $www         = WWW::Mechanize->new();
            my $stuff       = $www->get('http://ftb.gamepedia.com/api.php?action=query&meta=siteinfo&siprop=statistics&format=json') or die "Unable to get url.\n";
            my $decode      = $stuff->decoded_content();
            my @pages       = $decode =~ m{\"pages\":(.*?),};
            my @articulos   = $decode =~ m{\"articles\":(.*?),};
            my @edits       = $decode =~ m{\"edits\":(.*?),};
            my @images      = $decode =~ m{\"images\":(.*?),};
            my @users       = $decode =~ m{\"users\":(.*?),};
            my @activeusers = $decode =~ m{\"activeusers\":(.*?),};
            my @admins      = $decode =~ m{\"admins\":(.*?),};

            my $num_pages    = SatanicBot::Utils->separate_by_commas($pages[0]);
            my $num_articles = SatanicBot::Utils->separate_by_commas($articulos[0]);
            my $num_edits    = SatanicBot::Utils->separate_by_commas($edits[0]);
            my $num_images   = SatanicBot::Utils->separate_by_commas($images[0]);
            my $num_users    = SatanicBot::Utils->separate_by_commas($users[0]);
            my $num_active   = SatanicBot::Utils->separate_by_commas($activeusers[0]);
            my $num_admins   = SatanicBot::Utils->separate_by_commas($admins[0]);

            $self->say(
                channel => $channel,
                body    => "$num_pages pages || $num_articles articles || $num_edits edits || $num_images images || $num_users users || $num_active active users || $num_admins admins"
            );
        }
    }

    if ($msg =~ m/^\$calc(?: )/i) {
        my @calcwords = split /\s/, $msg, 2;
        if ($calcwords[1] =~ m/\d/) {
            my $out = eval $calcwords[1];
            $self->say(
                channel => $channel,
                body    => "$calcwords[1] = $out"
            );
        } elsif ($calcwords[1] =~ m/\D/) {
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

=pod
    if ($msg =~ m/^\$addminor/i) {
        if ($msg =~ m/^\$addminor(?: )/i) {
            my @minormodswords = split /\s/, $msg, 2;
            $self->say(
                channel => $channel,
                body    => "Adding \'$minormodswords[1]\' to the Minor Mods list."
            );

            SatanicBot::MediaWikiAPI->login();
            SatanicBot::MediaWikiAPI->edit_minor($minormodswords[1]);

            if ($SatanicBot::MediaWikiAPI::MINORCHECK eq 'false') {
                $self->say(
                    channel => $channel,
                    body    => 'Could not proceed. Mod already on the list.'
                );
            } elsif ($SatanicBot::MediaWikiAPI::MINORCHECK eq 'true') {
                $self->say(
                    channel => $channel,
                    body    => 'Success!'
                );
            }
        } else {
            $self->say(
                channel => $channel,
                body    => $args
            );
        }
    }
=cut

    if ($msg =~ m/^\$randnum/i) {
        my @randwords = split /\s/, $msg, 2;
        if ($randwords[1] =~ m/\d/) {
            $self->say(
                channel => $channel,
                body    => int rand $randwords[1] + 1
            );
        } else {
            $self->say(
                channel => $channel,
                body    => 'No argument provided. Using 100... ' . int rand 101
            );
        }
    }

    #Super hard number guessing game
    #Make it less hard you fuccboi
    if ($msg =~ m/^\$game/i) {
        if ($msg =~ m/^\$game [\d]/i){
            my @gamewords = split /\s/, $msg, 2;
            my $num = int rand 101;
            if ($gamewords[1] > 100) {
                $self->say(
                    channel => $channel,
                    body    => 'Please provide a number lower than 100.'
                );
            } elsif ($gamewords[1] eq $num) {
                $self->say(
                    channel => $channel,
                    body    => "Correct! The answer was $num"
                );
            } elsif ($gamewords[1] ne $num) {
                $self->say(
                    channel => $channel,
                    body    => "Wrong! The answer was $num"
                );
            }
        } elsif ($msg =~ m/^\$game int [\d]/i or $msg =~ m/^\$game float [\d]/i) {
            my @gamewords = split /\s/, $msg, 3;
            if ($gamewords[1] =~ m/int/i) {
                my $num = int rand 101;
                if ($gamewords[2] > 100) {
                    $self->say(
                        channel => $channel,
                        body    => 'Please provide a number lower than 100.'
                        );
                } elsif ($gamewords[2] eq $num) {
                    $self->say(
                        channel => $channel,
                        body    => "Correct! The answer was $num"
                    );
                } elsif ($gamewords[2] ne $num) {
                    $self->say(
                        channel => $channel,
                        body    => "Wrong! The answer was $num"
                    );
                }
            } elsif ($gamewords[1] =~ m/float/i) {
                my $num = rand 10;
                if ($gamewords[2] > 10) {
                    $self->say(
                        channel => $channel,
                        body    => 'Please provide a number lower than 10.'
                    );
                } elsif ($gamewords[2] eq $num) {
                    $self->say(
                        channel => $channel,
                        body    => "Correct! The answer was $num"
                    );
                } elsif ($gamewords[2] ne $num) {
                    $self->say(
                        channel => $channel,
                        body    => "Wrong! The answer was $num"
                    );
                }
            }
        } else {
            $self->say(
                channel => $channel,
                body    => $args
            );
        }
    }

    #LittleHelper is a LittleMotivational too. Suggested by Peter to motivate Kyth.
    if ($msg =~ m/^\$motivate/i) {
        my $file = File::RandomLine->new('info/motivate.txt');
        my $mess = $file->next(1);
        chomp $mess;
        if ($msg =~ m/^\$motivate(?: )/i) {
            my @who = split /\s/, $msg, 2;
            $self->say(
                channel => $channel,
                body    => "$mess, $who[1]"
            );
        } elsif ($msg =~ m/^\$motivate$/i) {
            $self->say(
                channel => $channel,
                body    => "$mess, $user"
            );
        }
    }

    #Twitter statistics for the provided user.
    if ($msg =~ m/^\$twitterstats/i) {
        if ($msg !~ m/^\$followers$/i) {
            my @username = split /\s/, $msg, 2;

            $ENV { PERL_LWP_SSL_VERIFY_HOSTNAME } = 0; #This is terrible.

            my $twitter = WWW::Twitter->new(username => $username[1]);
            my $stats = $twitter->stats;
            $self->say(
                channel => $channel,
                body    => "$username[1] has $stats->{followers} followers and is following $stats->{following} scrubs. They have made $stats->{total_status} status updates, and have posted $stats->{total_media} forms of non-written media. They have favorited $stats->{favorites} things."
            );
        } else {
            $self->say(
                channel => $channel,
                body    => $args
            );
        }
    }

    #Autotweet
    if ($msg =~ m/^\$tweet/i) {
        if ($msg !~ m/^\$tweet$/i) {
            my $lengthmsg = length $msg;
            if ($lengthmsg > 140) {
                $self->say(
                    channel => $channel,
                    body    => 'Sorry, that\'s too long.'
                );
            } else {
                my @tweet = split /\s/, $msg, 2;
                SatanicBot::Utils->get_secure_contents();
                $ENV {PERL_LWP_SSL_VERIFY_HOSTNAME} = 0; #This is terrible.
                my $twitter = WWW::Twitter->new(
                    username => $SatanicBot::Utils::LINES[2],
                    password => $SatanicBot::Utils::LINES[1]
                    );
                $twitter->login();
                my $status_id = $twitter->tweet("[IRC] $tweet[1]");
                $self->say(
                    channel => $channel,
                    body    => "Tweeted '$tweet[1]' https://twitter.com/LittleHelperBot/status/$status_id"
                );
            }
        } else {
            $self->say(
                channel => $channel,
                body    => $args
            );
        }
    }

    #Provides the user with a command list.
    if ($msg =~ m/^\$help/i) {
        if ($msg !~ m/\$help$/i) {
            my @helpwords = split /\s/, $msg, 2;
            if ($helpwords[1] =~ m/quit$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Stops the bot. No args.'
                );
            }
            if ($helpwords[1] =~ m/abbrv$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Abbreivates a mod for the tilesheet extension. 2 Args: <abbreviation> <mod name>'
                );
            }
            if ($helpwords[1] =~ m/spookyscaryskeletons$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Very spooky. No args. This command is broken.'
                );
            }
            if ($helpwords[1] =~ m/weather$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Provides weather information for the given place. 1 required arg, 1 optional arg: <(optional) f or c> <place>'
                );
            }
            if ($helpwords[1] =~ m/upload$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Uploads an image to the wiki. 2 args: <file link> <file name>'
                );
            }
            if ($helpwords[1] =~ m/osrc$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Links the open source report card for the user. 1 optional arg: <username>'
                );
            }
            if ($helpwords[1] =~ m/src$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Links the source code for this bot. No args.'
                );
            }
            if ($helpwords[1] =~ m/contribs$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Provides some user information including num of contribs to the wiki and registration date. 1 arg: <username>'
                );
            }
            if ($helpwords[1] =~ m/flip$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Heads or tails! No args'
                );
            }
            if ($helpwords[1] =~ m/8ball$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Determines your fortune. No args'
                );
            }
            if ($helpwords[1] =~ m/randquote$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Gives a random quote from the #FTB-Wiki IRC channel. No args'
                );
            }
            if ($helpwords[1] =~ m/stats$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Gives wiki stats. 1 optional arg: <pages or articles or edits or images or users or active users or admins>'
                );
            }
            if ($helpwords[1] =~ m/calc$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Derpy calculator. Takes an equation. This performs eval; if it doesn\'t work blame eval'
                );
            }
            if ($helpwords[1] =~ m/randnum$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Generates a random number. 1 optional arg, if not provided it will assume 0-100: <max num>'
                );
            }
            if ($helpwords[1] =~ m/game$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Number guessing game. 2 args: <int or float> <guess>'
                );
            }
            if ($helpwords[1] =~ m/motivate$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Motivates you or the user you provide in the first arg.'
                );
            }
            if ($helpwords[1] =~ m/tweet$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Tweets the first arg on the @LittleHelperBot Twitter account.'
                );
            }
            if ($helpwords[1] =~ m/twitterstas$/i) {
                $self->say(
                    channel => $channel,
                    body    => 'Provides statistics for the given user. Takes one argument: the username.'
                )
            }
        } else {
            $self->say(
                channel => $channel,
                body    => 'Listing commands... quit, abbrv, spookyscaryskeletons, weather, upload, osrc, src, contribs, flip, 8ball, randquote, stats, calc, randnum, game, motivate, tweet, twitterstats'
            );
        }
    }
}
1;
