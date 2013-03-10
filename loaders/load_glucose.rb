#!/usr/bin/ruby19
# load_glucose - load blood glucose readings from a Bayer Glucofacts DB into QSDB

require 'rubygems'
require 'sequel'
require 'date'
require 'yaml'

yaml = YAML.load_file "#{ENV['HOME']}/.qsrc"
db_hostname = yaml['db']['hostname']
db_database = yaml['db']['database']
db_username = yaml['db']['username']
db_password = yaml['db']['password']

if(!ARGV[0]) then
	puts "usage: #{$0} <db path>"
	exit 1
end
bayer_db_path = ARGV[0]

gfdb = Sequel.connect("sqlite://#{bayer_db_path}");
qsdb = Sequel.connect("mysql://#{db_hostname}/#{db_database}", :user => db_username, :password => db_password);
medcat = qsdb[:categories].filter(:category_name => "Medical").first[:id]
gluact = qsdb[:activities].filter(:activity_name => "Glucose").first[:id]
entries = qsdb[:point_entries]

readings = gfdb[:ResultData]
readings.each { |reading|
	glucose = sprintf "%1.1f", reading[:Measurement_Value]
	date = reading[:Test_Date] / 1000
	time_raw = reading[:Test_Time]
	unit = reading[:Reference_Unit]
	time = Time.at(time_raw[0..1].to_i*60*60 + time_raw[3..4].to_i*60 + time_raw[6..7].to_i)
	datetime = Time.at(date + time.to_i)
	
	if(entries.filter(:point_time => datetime, :activity_id => gluact, :value => glucose).count > 0) then
		puts "Skipping load of record as it already exists: #{datetime} #{glucose}"
	else
		puts "Loading record: #{datetime} #{glucose}"
		entries.insert(	:point_time 		=> datetime,
										:category_id		=> medcat,
										:activity_id		=> gluact,
										:unit						=> unit,
										:value					=> glucose)
	end
}

