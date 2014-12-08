SatanicBot
==========

SatanicBot IRC bot for accomplishing simple FTB Wiki tasks.

Commands
========

help
----
The $help command is used to provide information on commands to the users. It will output the following text to the channel:

Listing commands... quit, abbrv

To get info on a specific command, do $help \<command\>

abbrv
-----
The $abbrv command is used to add abbreviations to Template:G/Mods and its documentation. It takes two arguments, the abbreviation and the mod name. It will output the following to the channel (first line is before it runs the MediaWiki stuff, the second is after it is complete):

Abbreviating \<mod name\> as \<abbreviation\>

Abbreviation and documentation added.

spookyscaryskeletons
--------------------
The $spookyscaryskeletons command will output a random word from the spook.lines file, like EMACS. It takes no arguments.

quit
----
The $quit command will stop the bot.
