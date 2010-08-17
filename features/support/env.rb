require "bundler"
Bundler.setup(:default, :sinatra, :test)

require File.join(File.dirname(__FILE__), '..', '..', 'schoolmailer')

raise "Złe środowisko. Dodaj RACK_ENV=test przed poleceniem" if Schoolmailer.environment != 'test'

%w(capybara capybara/cucumber spec).each {|lib| require lib}

World do

  include Capybara
  include Spec::Expectations
  include Spec::Matchers

  #Capybara.app = Sinatra::Application
  Capybara.app = Schoolmailer

end

Before('@count-mails') do
  begin
    @files_count = Dir.new('/tmp/fake-mailer').entries.size
  rescue
    @files_count = 2
  end
end
