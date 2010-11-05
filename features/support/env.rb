# encoding: utf-8
require "bundler"
Bundler.setup(:default, :sinatra, :test)

require File.join(File.dirname(__FILE__), '..', '..', 'schoolmailer')

raise "Złe środowisko. Dodaj RACK_ENV=test przed poleceniem" if Schoolmailer.environment != 'test'

%w(capybara capybara/cucumber rspec mail).each {|lib| require lib}

World do

  Capybara.app = Schoolmailer

end
