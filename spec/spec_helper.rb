ENV['RACK_ENV'] ||= 'test'

require "rubygems"
require "bundler"
Bundler.setup(:default, :sinatra, :test)

require_relative "../schoolmailer"

require "sinatra"
require "rack/test"
require "rspec"
require "capybara"
require "capybara/dsl"

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

RSpec.configure do |config|
  config.include(Capybara)
  Capybara.app = Schoolmailer.new
end
