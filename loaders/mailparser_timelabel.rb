#!/usr/bin/ruby
# mailparser_timelabel - parse a mailed-in TimeLabel CSV export and run it through load_timelabel

require 'rubygems'
require 'mail'
require 'tempfile'
require 'yaml'

# TODO: this path shouldn't be hardcoded
qsrc_path = "/home/sarahemm"
yaml = YAML.load_file "#{qsrc_path}/.qsrc"
base_path = yaml['general']['base_path']
mail_allowed_from = yaml['mail']['allowed_from']

def fatal(why, origmail)
	Mail.deliver do
		from		origmail.to[0]
		to			origmail.from[0]
		subject "Re: #{origmail.subject}"
		body		why
	end
	Kernel.exit -1
end

message = $stdin.read
mail = Mail.new(message)
file = Tempfile.new("mailparser_timelabel")
fatal "Your address (#{mail.from}) does not have access to load data into QSDB.", mail if mail.from[0] != mail_allowed_from
fatal "Mail with invalid format received - not multipart", mail if !mail.multipart?
fatal "Mail with invalid format received - wrong number of parts", mail if mail.parts.length != 3
file.write mail.parts[1].body.decoded
file.size # this flushes the buffers as a side-effect, which we need
FileUtils.cp file.path, "#{base_path}/loaded_files/timelabel-#{Time.now.to_i}.csv"
Mail.deliver do
	from		mail.to[0]
	to			mail.from[0]
	subject "Re: #{mail.subject}"
	body		`HOME=#{qsrc_path} #{base_dir}/loaders/load_timelabel.rb #{file.path} 2>&1`
end

