# Copyright 2014 Eli Foster

package SatanicBot::Bot;
use warnings;
use strict;
use diagnostics;

use base qw(Bot::BasicBot);
use Data::Random;
use Data::Dumper;
use Weather::Underground;
use SatanicBot::MediaWikiAPI;
use SatanicBot::MediaWikiBot;
use SatanicBot::Utils;
use LWP::Simple;
use WWW::Mechanize;
use WWW::Twitter;
use Math::Symbolic;
use Date::Parse;
use File::RandomLine;
use Geo::IP;
use Switch;

my %bot_stuff_hash = (
    ops       => [],
    auth_pass => ''
);
my $bot_stuff = \%bot_stuff_hash;

#Use this subroutine definition for adding commands.
sub said {
    my ($self, $message) = @_;
    my $channel = $message->{channel};
    my $host = $message->{raw_nick};
    my $msg = $message->{body};
    my $user = $message->{who};
    my $ERROR = $!;
    my $args = 'Please provide the required arguments.';
    my $authorized = 'You must be authorized.';
    my @commands = ( #This isn't really used a whole lot yet because I'm lazy.
        'pass',
        'quit',
        'abbrv',
        'spookyscaryskeletons',
        'weather',
        'upload',
        'src',
        'contribs',
        'flip',
        '8ball',
        'randquote',
        'stats',
        'randnum',
        'game',
        'motivate',
        'tweet',
        # 'addminor',
        # 'addmod',
        'auth',
        'addquote',
        'checkpage',
        'addnav',
        'newmodcat',
        'newminorcat'
    );
    my @content = SatanicBot::Utils->get_secure_contents();
    $bot_stuff->{auth_pass} = $content[3];



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
            if ($authwords[1] eq $bot_stuff->{auth_pass}) {
                unless (grep { $_ eq $host } @{$bot_stuff->{ops}}) {
                    $self->say(
                        channel => 'msg',
                        who     => $user,
                        body    => "$user, you are now logged in."
                    );
                    push @{$bot_stuff->{ops}}, $host;
                } else {
                    $self->say(
                        channel => 'msg',
                        who     => $user,
                        body    => "$user, you are already logged in."
                    );
                }
            }
        } else {
            $self->say(
                channel => 'who',
                who     => $user,
                body    => $args
            );
        }
    }

    if ($msg =~ m/^\$quit/i) {
        if (grep { $_ eq $host } @{$bot_stuff->{ops}}) {
            if ($msg =~ m/^\$quit$/i) {
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => 'I don\'t love you anymore' #For some reason this does not get said before it quits in most cases.
                );
                $self->shutdown(); #Consider replacing the message said before it quits with an actual quit message.
                exit 0;
            }
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => $authorized
            );
        }
    }

    #Adds the <first arg abbreviation> to the G:Mods and doc as <second arg mod name>
    if ($msg =~  m/^\$abbrv/i) {
        if (grep { $_ eq $host } @{$bot_stuff->{ops}}) {
            if ($msg =~ m/^\$abbrv(?: )/i) {
                my @abbrvwords = split /\s/, $msg, 3;
                if ($abbrvwords[1] =~ m/.+/ and $abbrvwords[2] =~ m/.+/) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "Abbreviating \'$abbrvwords[2]\' as \'$abbrvwords[1]\'"
                    );

                    my $edit = system "ruby", "ftbcommands.rb", 'modmodule', $abbrvwords[1], $abbrvwords[2];

                    if ($edit == 0) {
                        $self->say(
                            channel => $channel,
                            who     => $user,
                            body    => 'Could not proceed. Abbreviation and/or name already on the list.'
                        );
                    } elsif ($edit == 1) {
                        $self->say(
                            channel => $channel,
                            who     => $user,
                            body    => 'Success!'
                        );
                    }
                } else {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => $args
                    );
                }
            }
        } else {
            $self->say(
                channel => $channel,
                body    => $authorized
            );
        }
    }

    if ($msg =~ m/^\$checkpage/i) {
        if ($msg =~ m/^\$checkpage(?: )/i) {
            my @pagewords = split /\s/, $msg, 2;
            my $check = system "ruby", "ftbcommands.rb", 'check', $pagewords[1];
            if ($check == 0) {
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => "$pagewords[1] does not exist."
                );
            } elsif ($check == 1) {
                my $pageurl = $pagewords[1] =~ s/\s/_/gr;
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => "$pagewords[1] does exist: http://ftb.gamepedia.com/$pageurl"
                );
            }
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => $args
            );
        }
    }

    if ($msg =~ m/^\$newmodcat/i) {
        if ($msg =~ m/^\$newmodcat(?: )/i) {
            if (grep { $_ eq $host } @{$bot_stuff->{ops}}) {
                my @catwords = split /\s/, $msg, 2;
                my $create = system "ruby", "ftbcommands.rb", 'cat', $catwords[1], 'major';

                if ($create == 1) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "$catwords[1] category created."
                    );
                } else {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "Did not create $catwords[1] category."
                    );
                }
            }
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => $args
            );
        }
    }

    if ($msg =~ m/^\$newminorcat/i) {
        if ($msg =~ m/^\$newminorcat(?: )/i) {
            if (grep { $_ eq $host } @{$bot_stuff->{ops}}) {
                my @catwords = split /\s/, $msg, 2;
                my $create = system "ruby", "ftbcommands.rb", 'cat', $catwords[1], 'minor';

                if ($create == 0) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "$catwords[1] category created."
                    );
                } else {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "Did not create $catwords[1] category."
                    );
                }
            }
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => $args
            );
        }
    }

    if ($msg =~ m/^\$addquote/i) {
        if (grep { $_ eq $host } @{$bot_stuff->{ops}}) {
            if ($msg =~ m/^\$addquote(?: )/i) {
                my @quotewords = split /\s/, $msg, 2;
                my $file = 'info/ircquotes.txt';
                open my $fh, '>>', $file or $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => "Could not open $file $ERROR"
                );
                print $fh "$quotewords[1]\n";
                close $fh;
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => 'Added to the quote list.'
                );
            } else {
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => $args
                );
            }
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => $authorized
            );
        }
    }

    #Uploads the <first arg image> to the wiki as <second arg name>.
    if ($msg =~ m/^\$upload/i) {
        if (grep { $_ eq $host } @{$bot_stuff->{ops}}) {
            if ($msg =~ m/^\$upload(?: )/i) {
                my @uploadwords = split /\s/, $msg, 3;
                if ($uploadwords[1] =~ m/.+/) {
                    if ($uploadwords[2] =~ m/.+/) {
                        my $upload = system "ruby", "ftbcommands.rb", 'upload', $uploadwords[1], $uploadwords[2];

                        if ($upload == 1) {
                            $self->say(
                                channel => $channel,
                                who     => $user,
                                body    => "Uploaded \'$uploadwords[2]\' to the Wiki."
                            );
                        } else {
                          $self->say(
                              channel => $channel,
                              who     => $user,
                              body    => "Could not upload \'$uploadwords[2]\' to the Wiki."
                          );
                        }
                    } else {
                        my $upload = system "ruby", "ftbcommands.rb", 'upload', $uploadwords[1];

                        if ($upload == 1) {
                            $self->say(
                                channel => $channel,
                                who     => $user,
                                body    => "Uploaded \'$uploadwords[1]\' to the Wiki."
                            );
                        } else {
                          $self->say(
                              channel => $channel,
                              who     => $user,
                              body    => "Could not upload \'$uploadwords[1]\' to the Wiki."
                          );
                        }
                    }
                } else {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => $args
                    );
                }
            }
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => $authorized
            );
        }
    }

    if ($msg =~ m/^\$addnav/i) {
        if (grep { $_ eq $host } @{$bot_stuff->{ops}}) {
            if ($msg =~ m/^\$addnav(?: )/i) {
                my @templatewords = split /\s/, $msg, 2;
                if ($templatewords[1] =~ m/.+/) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "Adding $templatewords[1] to the Navbox list."
                    );

                    my $add = system "ruby", "ftbcommands.rb", 'nav', $templatewords[1], $templatewords[2];
                    if ($add == 0) {
                        $self->say(
                            channel => $channel,
                            who     => $user,
                            body    => 'That is already on the list.'
                        );
                    } else {
                        $self->say(
                            channel => $channel,
                            who     => $user,
                            body    => 'Success!'
                        );
                    }
                }
            } else {
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => $args
                );
            }
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => $authorized
            );
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
            who     => $user,
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
                        who     => $user,
                        body    => "$forecast->[0]->{place}: $forecast->[0]->{conditions} || Temperature: $forecast->[0]->{fahrenheit} F || Humidity: $forecast->[0]->{humidity}% || Last updated: $forecast->[0]->{updated}"
                    );
                } else {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "\'$weatherwords[2]\' is not a valid place."
                    );
                }
            } else {
                $self->say(
                    channel => $channel,
                    who     => $user,
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
                        who     => $user,
                        body    => "$forecast->[0]->{place}: $forecast->[0]->{conditions} || Temperature: $forecast->[0]->{celsius} C || Humidity: $forecast->[0]->{humidity}% || Last updated: $forecast->[0]->{updated}"
                    );
                } else {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "\'$weatherwords[2]\' is not a valid place."
                    );
                }
            } else {
                $self->say(
                    channel => $channel,
                    who     => $user,
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
                        who     => $user,
                        body    => "$forecast->[0]->{place}: $forecast->[0]->{conditions} || Temperature: $forecast->[0]->{fahrenheit} F || Humidity: $forecast->[0]->{humidity}% || Last updated: $forecast->[0]->{updated}"
                    );
                } else {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "\'$weatherwords[1]\' is not a valid place."
                    );
                }
            } else {
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => $args
                );
            }
        }
    }
=pod
    if ($msg =~ m/^\$weatherforecast(?: )/i) {
        if ($msg =~ m/\$weatherforecast f(?: )/i) {
            my @weatherwords = split /\s/, $msg, 3;
            if ($weatherwords[2] =~ m/[\p{IsAlphabetic}\d,]/) {
                my $weather = Weather::Underground->new(
                    place => $weatherwords[2]
                );

                my $forecast = $weather->getweather();

                if (exists $forecast->[0]->{place}) {
                    for (my $day = 0; $day < 7; $day++) {
                        my $daysay = $day + 1;
                        $self->say(
                            channel => 'msg',
                            who => $user,
                            body    => "Day $daysay: $forecast->[$day]->{place}: $forecast->[$day]->{conditions} || Temperature: $forecast->[$day]->{fahrenheit} F || Humidity: $forecast->[$day]->{humidity}% || Last updated: $forecast->[$day]->{updated}"
                        );
                    }
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
        } elsif ($msg =~ m/\$weatherforecast c(?: )/i) {
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

    #Outputs the link to this bot's source code.
    if ($msg =~ m/^\$src$/i) {
        $self->say(
            channel => $channel,
            who     => $user,
            body    => 'This bot was created by SatanicSanta, or Eli Foster: https://github.com/elifoster/SatanicBot'
        );
    }

    #Outputs how many contributions the user has made to the wiki.
    #Consider using a JSON parser instead of regular expression.
    if ($msg =~ m/^\$contribs(?: )/i) {
        my @contribwords = split /\s/, $msg, 2;
        if ($contribwords[1] =~ m/.+/) {
            my $contribs = system "ruby", "ftbcommands.rb", 'contribs', $contribwords[1]
            my $register = system "ruby", "ftbcommands.rb", 'registrationdate', $contribwords[1]

            if ($contribs eq 'nouser') {
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => 'Something went wrong. You may have entered an invalid username (such as an IP) or a nonexistant username.'
                );
            }
            } else {
                if ($contribs eq '1') {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "$contribwords[1] has made 1 contribution to the wiki and registered on $register."
                    );
                } elsif ($contribwords[1] eq 'SatanicBot' or $contribwords[1] eq 'satanicBot') {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "I have made $contribs contributions to the wiki and registered on $register."
                    );
                } elsif ($contribwords[1] eq 'TheSatanicSanta' or $contribwords[1] eq 'theSatanicSanta') {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "The second hottest babe in the channel has made $contribs contributions to the wiki and registered on $register."
                    );
                } elsif ($contribwords[1] eq 'Retep998' or $contribwords[1] eq 'retep998') {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "The hottest babe in the channel has made $contribs contributions to the wiki and registered on $register."
                    );
                } elsif ($contribwords[1] eq 'PonyButt' or $contribwords[1] eq 'ponyButt') {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "Some bitch ass nigga has made $contribs contributions to the wiki and registered on $register."
                    );
                } else {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "$contribwords[1] has made $contribs contributions to the wiki and registered on $register."
                    );
                }
            }
        }
    }

    if ($msg =~ m/^\$contribs$/i) {
        my $contribs = system "ruby", "ftbcommands.rb", 'contribs', $user
        my $register = system "ruby", "ftbcommands.rb", 'registrationdate', $user

        if ($contribs ne 'nouser') {
            if ($contribs eq '1') {
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => "$user, you have made 1 contribution to the wiki and registered on $register."
                );
            } else {
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => "$user, you have made $contribs contributions to the wiki and registered on $register."
                );
            }
        } elsif ($contribs eq 'nouser') {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => 'Something went wrong. You may have entered an invalid username (such as an IP) or a nonexistant username.'
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
            who     => $user,
            body    => $fortune
        );
    }

    #50/50 chance of outputting heads or tails.
    if ($msg =~ m/^\$flip$/i) {
        my $coin = int rand 2;
        if ($coin eq 1) {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => 'Heads!'
            );
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
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
            who     => $user,
            body    => $quote
        );
    }

    #Wiki statistics.
    #Consider using a real JSON parser rather than regular expression.
    #Refactor into Ruby code.
    if ($msg =~ m/^\$stats/i) {
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

        if ($msg =~ m/^\$stats$/i) {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => "$num_pages pages || $num_articles articles || $num_edits edits || $num_images images || $num_users users || $num_active active users || $num_admins admins"
            );
        } elsif ($msg =~ m/^\$stats(?: )/i) {
            my @statwords = split /\s/, $msg, 2;
            my $message;
            switch ($statwords[1]) {
                case m/^pages$/i {
                    $message = "The wiki has $num_pages pages.";
                }
                case m/^articles$/i {
                    $message = "The wiki has $num_articles articles.";
                }
                case m/^edits$/i {
                    $message = "The wiki has $num_edits edits.";
                }
                case m/^images$/i {
                    $message = "The wiki has $num_images images.";
                }
                case m/^users$/i {
                    $message = "The wiki has $num_users users.";
                }
                case m/^active users$/i {
                    $message = "The wiki has $num_active active users.";
                }
                case m/^admins$/i {
                    $message = "The wiki has $num_admins admins.";
                }
            }
            $self->say(
                channel => $channel,
                who     => $user,
                body    => $message
            );
        }
    }

=pod
    if ($msg =~ m/^\$addminor/i) {
        if ($msg =~ m/^\$addminor(?: )/i) {
            if (grep { $_ eq $host } @{$bot_stuff->{ops}}) {
                my @minormodswords = split /\s/, $msg, 2;
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => "Adding \'$minormodswords[1]\' to the Minor Mods list."
                    );

                SatanicBot::MediaWikiAPI->login();
                my $edit = SatanicBot::MediaWikiAPI->edit_minor($minormodswords[1]);

                if ($edit =~ m/\W/) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => $edit
                    );
                } elsif ($edit == 0) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => 'Could not proceed. Mod already on the list or mod page returned missing.'
                    );
                } elsif ($edit == 1) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => 'Success!'
                    );
                }
            } else {
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => $authorized
                );
            }
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => $args
            );
        }
    }

    if ($msg =~ m/^\$addmod/i) {
        if ($msg =~ m/^\$addmod(?: )/i) {
            if (grep { $_ eq $host } @{ $bot_stuff->{ops} }) {
                my @modwords = split /\s/, $msg, 2;
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => "Adding \'$modwords[1]\' to the Mods list."
                );

                SatanicBot::MediaWikiAPI->login();
                my $edit = SatanicBot::MediaWikiAPI->edit_mods($modwords[1]);

                if ($edit == 0) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => 'Could not proceed. Mod already on the list or mod page returned missing.'
                    );
                } elsif ($edit == 1) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => 'Success!'
                    );
                }
            } else {
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => $authorized
                );
            }
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => $args
            )
        }
    }
=cut

    if ($msg =~ m/^\$randnum/i) {
        my @randwords = split /\s/, $msg, 2;
        if ($randwords[1] =~ m/\d/) {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => int rand $randwords[1] + 1
            );
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
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
                    who     => $user,
                    body    => 'Please provide a number lower than 100.'
                );
            } elsif ($gamewords[1] eq $num) {
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => "Correct! The answer was $num"
                );
            } elsif ($gamewords[1] ne $num) {
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => "Wrong! The answer was $num"
                );
            }
        } elsif ($msg =~ m/^\$game int [\d]/i or $msg =~ m/^\$game float [\d]/i) {
            my @gamewords = split /\s/, $msg, 3;
            $gamewords[2] =~ s/\D//g;
            if ($gamewords[1] =~ m/int/i) {
                my $num = int rand 101;
                if ($gamewords[2] > 100) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => 'Please provide a number lower than 100.'
                        );
                } elsif ($gamewords[2] eq $num) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "Correct! The answer was $num"
                    );
                } elsif ($gamewords[2] ne $num) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "Wrong! The answer was $num"
                    );
                }
            } elsif ($gamewords[1] =~ m/float/i) {
                my $num = rand 10;
                if ($gamewords[2] > 10) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => 'Please provide a number lower than 10.'
                    );
                } elsif ($gamewords[2] eq $num) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "Correct! The answer was $num"
                    );
                } elsif ($gamewords[2] ne $num) {
                    $self->say(
                        channel => $channel,
                        who     => $user,
                        body    => "Wrong! The answer was $num"
                    );
                }
            }
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
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
                who     => $user,
                body    => "$mess, $who[1]"
            );
        } elsif ($msg =~ m/^\$motivate$/i) {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => "$mess, $user"
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
                    who     => $user,
                    body    => 'Sorry, that\'s too long.'
                );
            } else {
                my @tweet = split /\s/, $msg, 2;
                SatanicBot::Utils->get_secure_contents();
                $ENV {PERL_LWP_SSL_VERIFY_HOSTNAME} = 0; #This is terrible.
                my @secure = SatanicBot::Utils->get_secure_contents();
                my $twitter = WWW::Twitter->new(
                    username => $secure[2],
                    password => $secure[1]
                );
                $twitter->login();
                my $status_id = $twitter->tweet("[IRC] $tweet[1]");
                $self->say(
                    channel => $channel,
                    who     => $user,
                    body    => "Tweeted '$tweet[1]' https://twitter.com/LittleHelperBot/status/$status_id"
                );
            }
        } else {
            $self->say(
                channel => $channel,
                who     => $user,
                body    => $args
            );
        }
    }

    #Provides the user with a command list.
    if ($msg =~ m/^\$help/i) {
        if ($msg !~ m/\$help$/i) {
            my @helpwords = split /\s/, $msg, 2;
            my $helpfulmessage;

            switch ($helpwords[1]) {
                case m/quit$/i {
                    $helpfulmessage = 'Murders me. An op-only command. No args.';
                }
                case m/abbrv$/i {
                    $helpfulmessage = 'Abbreivates a mod for the tilesheet extension. An op-only command. 2 args: <abbreviation> <mod name>';
                }
                case m/spookyscaryskeletons$/i {
                    $helpfulmessage = 'Very spooky. No args. This command is broken.';
                }
                case m/weather$/i {
                    $helpfulmessage = 'Provides weather information for the given place. 1 required arg, 1 optional arg: <(optional) f or c> <place>';
                }
                case m/upload$/i {
                    $helpfulmessage = 'Uploads an image to the wiki. An op-only command. 2 args: <file link> <file name>';
                }
                case m/src$/i {
                    $helpfulmessage = 'Links the source code for myself. No args.';
                }
                case m/contribs$/i {
                    $helpfulmessage = 'Provides some user information including num of contribs to the wiki and registration date. 1 optional arg: <username>. If no arg is given, I will use the user\'s IRC nickname.';
                }
                case m/flip$/i {
                    $helpfulmessage = 'Heads or tails! No args';
                }
                case m/8ball$/i {
                    $helpfulmessage = 'Determines your fortune. No args';
                }
                case m/randquote$/i {
                    $helpfulmessage = 'Gives a random quote from the #FTB-Wiki IRC channel. No args';
                }
                case m/stats$/i {
                    $helpfulmessage = 'Gives wiki stats. 1 optional arg: <pages or articles or edits or images or users or active users or admins>';
                }
                case m/randnum$/i {
                    $helpfulmessage = 'Generates a random number. 1 optional arg, if not provided I will assume 0-100: <max num>';
                }
                case m/game$/i {
                    $helpfulmessage = 'Number guessing game. 2 args: <int or float (optional)> <guess>. If no first arg is given I will assume int.';
                }
                case m/motivate$/i {
                    $helpfulmessage = 'Motivates you or the user you provide in the first arg.';
                }
                case m/tweet$/i {
                    $helpfulmessage = 'Tweets the first arg on the @LittleHelperBot Twitter account.';
                }
                case m/pass$/i {
                    $helpfulmessage = 'Sets the auth password. Only Santa can do this command.';
                }
                case m/auth$/i {
                    $helpfulmessage = 'Logs the user in, allowing for op-only commands. 1 arg: $auth <password>';
                }
                #case m/addminor$/i {
                #    $helpfulmessage = 'Adds a mod to the list of minor mods on the main page. 1 arg: $addminor <mod name>';
                #}
                # case m/addmod$/i {
                    # $helpfulmessage = 'Adds a mod to the list of mods on the main page. 1 arg: $addmod <mod name>';
                # }
                case m/addquote$/i {
                    $helpfulmessage = 'Adds the first argument to the list of quotes used by $randquote.';
                }
                case m/checkpage$/i {
                    $helpfulmessage = 'Checks if the first argument is a valid page.';
                }
                case m/addnav$/i {
                    $helpfulmessage = 'If the template and page are both valid, adds the navbox in the first arg to the template list.';
                }
                case m/newmodcat$/i {
                    $helpfulmessage = 'Creates a new category for the mod given in the first arg.';
                }
                case m/newminorcat$/i {
                    $helpfulmessage = 'Creates a new category for the minor mod given in the first arg.';
                }
            }
            $self->say(
                channel => $channel,
                who     => $user,
                body    => $helpfulmessage
            );
        } else {
            my @sort = sort @commands;
            my $join = join ', ', @sort;
            $self->say(
                channel => $channel,
                who     => $user,
                body    => 'My activation char is $. Listing commands... ' . $join
            );
        }
    }
}
1;
