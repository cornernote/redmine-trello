Redmine-Trello Integration
==========================

This project provides full synchronization of
Redmine tickets to Trello boards.

This project synchronizes the following with a trello card
* the ticket owner (adding them as a member to the trello card)
* the ticket comments and keeps them up to date on each sync.
* the ticket changesets (adding them as comments) and keeps them up to date on each sync.
* It synchronizes the ticket status as a label
	
This also will keep the trello cards synchronized with the redmine ticket as long as the ticket stays in the same list is was created in or check_all_lists is set to true.

Recent versions also have the ability to create Trello cards
from github pull requests.

Prerequisites
-------------
* Requires ruby 1.9 because it uses some of the newer character
  encoding features

Installation
------------
* Clone this git repo
* Make a copy of `config/redmine_trello_config.rb.SAMPLE`
   to `config/redmine_trello_config.rb`
* Edit the config file, following the instructions from
   the sample file to configure your trello access tokens,
   your mappings from Redmine projects / issue states and
   your mappings from Redmine users
   to the Trello lists you'd like to clone the issues into
* Set up a cron job that calls `bin/copy_to_trello.rb` or if you are using rvm `bin/run_rmv.sh` at
   your desired interval

Compatibility
-------------
We are currently running this script against Redmine 2.5.1.
It has not been tested with any other versions.

