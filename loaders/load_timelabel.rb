#!/usr/bin/ruby19
# load_timelabel - Load data from the iPhone TimeLabel app's CSV exports into QSDB.

require 'rubygems'
require 'sequel'
require 'date'
require 'yaml'
require 'csv'

yaml = YAML.load_file "#{ENV['HOME']}/.qsrc"
db_hostname = yaml['db']['hostname']
db_database = yaml['db']['database']
db_username = yaml['db']['username']
db_password = yaml['db']['password']

db = Sequel.connect("mysql://#{db_hostname}/#{db_database}", :user => db_username, :password => db_password);
categories = db[:categories]
activities = db[:activities]
log = db[:log_entries]

recs_skipped = recs_loaded = 0
CSV.foreach(ARGV.shift) do |row|
	start_date, start_time, end_date, end_time, duration, category, activity, notes = row
	next if start_date.downcase == "start date" # skip header
	category = "Sleep" if category == "" and activity.downcase == "sleep"
	start_datetime = DateTime.strptime("#{start_date} #{start_time}", '%m/%d/%Y %H:%M:%S')
	end_datetime   = DateTime.strptime("#{end_date} #{end_time}", '%m/%d/%Y %H:%M:%S')
	if(log.filter(:start_time => start_datetime, :end_time => end_datetime).count > 0) then
		puts "Skipping load of record as it already exists: #{start_date} #{start_time} #{category} #{activity}"
		recs_skipped += 1
		next
	else
		puts "Loading record: #{start_date} #{start_time} #{category} #{activity}"
	end
	recs_loaded += 1
	cat_id = nil
	this_cat = categories.filter(:category_name => category)
	if(this_cat.count == 0) then
		# add the new category
		puts "Adding new category '#{category}'"
		cat_id = categories.insert(:category_name => category)
	else
		cat_id = this_cat.first[:id]
	end
	
	this_act = activities.filter(:category_id => cat_id, :activity_name => activity)
	if(this_act.count == 0) then
		# add the new activity
		puts "Adding new activity '#{activity}' under category '#{category}'"
		act_id = activities.insert(:category_id => cat_id, :activity_name => activity)
	else
		act_id = this_act.first[:id]
	end
	
	log.insert(	:start_time 	=> start_datetime,
							:end_time			=> end_datetime,
							:category_id	=> cat_id,
							:activity_id	=> act_id)
end

puts ""
puts "#{recs_loaded} records loaded successfully, #{recs_skipped} records skipped."
