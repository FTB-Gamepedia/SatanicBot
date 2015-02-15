SatanicBot
==========

SatanicBot written in Perl. This is an IRC and FTB Wiki bot (MediaWiki API) that can help do things easier.

Normal commands
========

help
----
The $help command will output a list of commands to the channel. It can take a single argument of a command's name to provide information on how it is used.

weather
-------
The $weather command is used to get the weather for the day. It will give the high, low, and chance of precipitation in the provided area. It takes on argument, location. The location can be any of the following:
- city,state 		Example: Portland,Oregon
- zip code		Example: 11030
- latitude,longitude	Example: 21.3069444,-157.8583333

spookyscaryskeletons
--------------------
The $spookyscaryskeletons command will output a random word from the spook.lines file, like EMACS. It takes no arguments.

upload
------
The $upload command will upload the first argument file to the wiki with the file name of the second argument.

contribs
--------
The $contribs command will state the first argument's number of contributions to the wiki. If no arg is given, it will use the user's nick.

flip
----
The $flip command will generate a random integer of either 1 or 0. If it is 1 it will say "Heads!", if it is 0 it will say "Tails!".

8ball
-----
The $8ball command will output a random sentence from 8ball.txt.

randquote
---------
The $randquote command will output a random quote from ircquotes.txt. These are all from the #FTB-Wiki channel.

stats
-----
The $stats command will output statistics for the wiki. It has one optional argument, and can take 'pages', 'articles', 'edits', 'images', 'users', 'active users', or 'admins' as the args. They will output the stats accordingly.

calc
----
Used to add/subtract/divide/multiply two numbers. Takes 3 arguments: $calc <first num> <sign +-/* <second num>

randnum
-------
Generates a random integer between 0 and the number defined in the first arg (inclusive).

game
----
Random number guessing game. Takes 2 arguments: <int or float> <number>. Integers will be from 0-100. Floats will be from 0-10.

motivate
--------
Motivates the provided user, or, if none is provided, the user who sent the message.

tweet
-----
Sends a tweet on the LittleHelperBot Twitter.

twitterstats
------------
Gets statistics for the Twitter user given in the first arg. It's sort of broken due to a crappy Twitter module.

auth
----
Logs the user in, allowing for op-only commands. It requires the password set by the $pass command.

checkpage
---------
Checks if the page provided in the first argument is valid.



Restricted commands
===================
These commands can only be used by authorized users or Santa specifically.

quit
----
The $quit command will stop the bot. All authorized users can use this command.

pass
----
Used to set the password for authorization. Only Santa can use this command.

abbrv
-----
The $abbrv command is used to add abbreviations to Template:G/Mods and its documentation. It takes two arguments, the abbreviation and the mod name.

addminor
--------
Adds the mod provided with the first argument to the list of Minor Mods on the Main Page.

addmod
------
Adds the mod provided with the first argument to the list of Mods on the Main Page.

addquote
--------
Adds the quote provided with the first argument to the list of quotes used by the randquote command.