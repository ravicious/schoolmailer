# encoding: utf-8
Given /I have submitted email "([^\"]*)"/ do |email|
  Given "I am on the homepage"
  When "I fill in \"email\" with \"#{email}\""
  When %q{I press "Wchodzę w to!"}
  Then "I should receive activation email"

  @confirmation_link = @activation_mail.body.match(/^(http.+)$/)[0]
end

Given /I have confirmed email "([^\"]*)"/ do |email|
  Given "I have submitted email \"#{email}\""
  When "I open the confirmation link"
  Then "I should receive email that confirms activation"

  @unsubscribe_link = @activation_confirmed_mail.body.match(/^(http.+)$/)[0]
end

When /I open the confirmation link/ do
  visit @confirmation_link
end

When /I open the unsubscribe link/ do
  visit @unsubscribe_link
end

Then /I should receive activation email/ do
  @activation_mail = Mail::TestMailer.deliveries.last
  @activation_mail.subject.should match(/Aktywacja konta/)
end

Then /I should receive email that confirms activation/ do
  @activation_confirmed_mail = Mail::TestMailer.deliveries.last
  @activation_confirmed_mail.subject.should match(/Aktywacja konta powiod/)
end
