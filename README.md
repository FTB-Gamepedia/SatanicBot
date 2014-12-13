SatanicBot
==========

SatanicBot written in Perl. This is an IRC and FTB Wiki bot (MediaWiki API) that can help do things easier.

IRC Commands
========

help
----
The $help command will output a list of commands to the channel.

abbrv
-----
The $abbrv command is used to add abbreviations to Template:G/Mods and its documentation. It takes two arguments, the abbreviation and the mod name. It will output the following to the channel (first line is before it runs the MediaWiki stuff, the second is after it is complete):

Abbreviating \<mod name\> as \<abbreviation\>

Abbreviation and documentation added.

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
The $contribs command will state the first argument's number of contributions to the wiki.

quit
----
The $quit command will stop the bot.
