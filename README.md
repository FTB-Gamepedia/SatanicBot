# SatanicBot
[![License](https://img.shields.io/:license-mit-blue.svg)]()

SatanicBot is a Discord and FTB Wiki bot written in Ruby (formerly Perl 5). It utilizes custom Ruby Gems created by myself and others at the FTB Wiki, such as string-utility, mediawiki-butt, and weatheruby, and Ruby gems by other awesome developers, such as sferik's twitter gem.

It allows for configuration, so you are free to use this in your Discord servers. The only downfall to the current configuration system is that you must have something to put in all of the options. However, if you never use the commands, or disable/delete them altogether, it really shouldn't matter what you put in there.

You can find this bot in its purest form in the FTB Wiki Discord.

## Features
* Configuration
    * This bot is fully configurable and modular. See the wiki for detailed information on configuration, or just take a look .example for the example .env file.
  * Web compatible
    * The actual bot in its purest and most complete form runs on a Heroku service, using a pseudo config.ru and Procfile. If using a web service such as Heroku, the environment variables will need to be set as that service requires, otherwise, running locally can be done easily with a .env file.
   * Many commands
     * Though many of the commands are very specific to the FTB Gamepedia's needs, a bunch of the other commands are "non-specific" in that regard. Take a look in the plugins directory.


## Usage
To use SatanicBot, you will first need to clone the repository:

```shell
$ git clone https://github.com/FTB-Gamepedia/SatanicBot.git
```

Then, you need to create the configuration file. Previously, this was a YAML file, however, now it uses environment variables. So, if you are running it locally, use a .env file, otherwise set the environment variables normally. See the wiki for configuration details.

Before running, you will need to run `bundle install` in order for all of the gems to install. This may take a while, as this has a wide range of dependencies.

Once all of the Gems and correct Ruby version (2.3.0) are installed, it is ready to be run. If running simply `ruby run.rb` errors, use `bundle exec ruby run.rb`. If it still errors, report it at the issue tracker.

## Contributing
This project is open source under the MIT license. Contributions adhere to that license.

* When contributing code, always run `rubocop -c .rubocop.yml` before committing. This will ensure it follows the project's code style.
* Avoid committing directly to master, as always, and either fork or branch your major changes. Bug fixes, typos, etc. are fine to be pushed directly to master.
* Always be detailed in your pull requests. Describe any design choices you had to make, as well as any limitations or problems the feature may have.
