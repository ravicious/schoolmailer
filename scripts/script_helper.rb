# encoding: utf-8
ENV['RACK_ENV'] ||= 'development'
require "rubygems"
require "bundler"

Bundler.setup(:default, :scripts)

%w(dm-core dm-validations dm-timestamps dm-migrations).each {|lib| require lib}

require_relative "../lib/simple_config_file"
require_relative "../lib/string/remove_empty_spaces"

load_config 'conf/settings.yml'
load_config "conf/#{ENV['RACK_ENV']}.settings.yml"

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/schoolmailer_#{ENV['RACK_ENV']}.sqlite3")
# Config dla postgresa
#DataMapper.setup(:default, "postgres://#{$config['database_login']}:#{$config['database_pass']}@localhost/schoolmailer_#{ENV['RACK_ENV']}")

%w(email replacement drawn_number).each do |model|
  require File.join(File.dirname(File.expand_path(__FILE__)), '..', 'models', model)
end

DataMapper.finalize
DataMapper.auto_upgrade!

if ENV['RACK_ENV'] == 'development'
  DataMapper::Logger.new($stdout, :debug)
end