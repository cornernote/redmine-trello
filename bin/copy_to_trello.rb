#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "config")
$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "lib")

#
# This is a command-line program that will read the redmine_trello_conf.rb config file,
# find unreviewed issues on the specified redmine project, and create cards for them on the
# specified Trello list. If a card appears in the Trello list that does not appear in the
# unreviewed tickets, then the card will be removed from the list.
#
# Multiple mappings from redmine projects to Trello lists can be setup in the redmine_trello_conf.rb
# file. The mappings are allowed to point to the same Trello list, as well.
#

require 'rmt/config'
require 'redmine_trello_conf'
require 'rmt/synchronize'

last_run = DateTime.commercial(2002)
tmp_file = File.join(File.absolute_path(File.dirname(__FILE__)), "last_run")

begin
		if File.exist?(tmp_file)
				file = File.open(tmp_file, "r")
				last_run = Date.parse(file.readline)
				file.close
		end

		file = File.open(tmp_file, "w+")
		file.puts DateTime.now.to_s
rescue IOError => e
		#some error occur, dir not writable etc.
		 puts e.to_s.strip()
		exit(1)
ensure
		file.close unless file == nil
end
		
RMT::Config.
  mappings.
  inject(RMT::Synchronize.new) do |sync, mapping|
    sync.synchronize(mapping.source.data_for(mapping.trello, last_run), mapping.trello)
  end.
  finish
