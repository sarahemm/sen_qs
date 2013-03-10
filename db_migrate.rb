#!/usr/bin/ruby19
# db_migrate - Run any migrations required to get the QSDB up to date schema-wise

require 'rubygems'
require 'sequel'
require 'yaml'

yaml = YAML.load_file "#{ENV['HOME']}/.qsrc"
db_hostname = yaml['db']['hostname']
db_database = yaml['db']['database']
db_username = yaml['db']['username']
db_password = yaml['db']['password']

Sequel.extension :migration, :core_extensions

db = Sequel.connect("mysql://#{db_hostname}/#{db_database}", :user => db_username, :password => db_password);
if(Sequel::Migrator.is_current?(db, "./migrations")) then
  puts "Schema of #{db_database} is already up to date."
else
  puts "Bringing schema of #{db_database} up to date..."
  Sequel::Migrator.run(db, "./migrations");
end

