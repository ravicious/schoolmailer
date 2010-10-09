require "rubygems"
require "bundler"
Bundler.setup(:default, :sinatra)

require "sinatra"
require File.join(File.dirname(__FILE__), 'schoolmailer')
run Schoolmailer
