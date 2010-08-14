require "bundler"
Bundler.setup(:default, :sinatra, :test)

require File.join(File.dirname(__FILE__), '..', '..', 'schoolmailer')
%w(capybara capybara/cucumber spec).each {|lib| require lib}

World do

  include Capybara
  include Spec::Expectations
  include Spec::Matchers

  #Capybara.app = Sinatra::Application
  Capybara.app = Schoolmailer

end
