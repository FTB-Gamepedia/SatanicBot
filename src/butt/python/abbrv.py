# Created by SatanicSanta

import sys

name = raw_input("What is the mod's name?\n")
abbrev = raw_input("What would you like its abbreviation to be?\n")

print("|" + abbrev + " = {{#if:{{{name|}}}{{{code|}}}||_(}}{{#if:{{{name|}}}{{{link|}}}|" + name + "|" + abbrev + "}}{{#if:{{{name|}}}{{{code|}}}||)}}\n|" + name + " = {{#if:{{{name|}}}{{{code|}}}||_(}}{{#if:{{{name|}}}{{{link|}}}|" + name + "|" + abbrev + "}}{{#if:{{{name|}}}{{{code|}}}||)}}")

sys.exit()
