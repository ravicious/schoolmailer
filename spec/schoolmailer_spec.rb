# encoding: utf-8
require_relative "spec_helper"

describe "Schoolmailer" do
  include Rack::Test::Methods

  def app
    Schoolmailer
  end

  it "should not send an registration email if there are no free SendGrid's credits" do
    Schoolmailer.stub!(:enough_of_free_credits?).and_return(false)
    visit '/'
    fill_in 'email', :with => 'enoughof@freecredits.pl'
    click_button "Wchodzę w to!"
    page.should have_content("24 godziny")
  end
end
