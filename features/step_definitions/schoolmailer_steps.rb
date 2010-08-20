Given /I have submitted email "([^\"]*)"/ do |email|
  Given "I am on the homepage"
  When "I fill in \"email\" with \"#{email}\""
  When %q{I press "Wchodzę w to!"}
  Then "I should receive activation email"

  @confirmation_link = File.read("/tmp/fake-mailer/#{@activation_mail}").match(/^(http.+)$/)[0]
end

Given /I have confirmed email "([^\"]*)"/ do |email|
  Given "I have submitted email \"#{email}\""
  When "I open the confirmation link"
  Then "I should receive email that confirms activation"

  @unsubscribe_link = File.read("/tmp/fake-mailer/#{@activation_confirmed_mail}").match(/^(http.+)$/)[0]
end

When /I open the confirmation link/ do
  visit @confirmation_link
end

When /I open the unsubscribe link/ do
  visit @unsubscribe_link
end

Then /I should receive activation email/ do
  @activation_mail = Dir.new('/tmp/fake-mailer').entries.sort.last
  File.read("/tmp/fake-mailer/#{@activation_mail}").should match(/Aktywacja_konta/)
end

Then /I should receive email that confirms activation/ do
  @activation_confirmed_mail = Dir.new('/tmp/fake-mailer').entries.sort.last
  File.read("/tmp/fake-mailer/#{@activation_confirmed_mail}").should match(/Aktywacja_konta_powiod/)
end
