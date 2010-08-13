require "rubygems"
require "bundler"
Bundler.setup(:default, :sinatra)

require "sinatra"
require "schoolmailer"
run Schoolmailer
