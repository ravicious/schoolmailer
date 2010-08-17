Given /I have submitted email "([^\"]*)"/ do |email|
  Given "I am on the homepage"
  When "I fill in \"email\" with \"#{email}\""
  When %q{I press "→"}
  Then "I should receive activation email"

  @confirmation_link = File.read("/tmp/fake-mailer/#{@activation_mail}").match(/^(http.+)$/)[0]
end

When /I open the confirmation link/ do
  visit @confirmation_link
end

Then /I should receive activation email/ do
  @activation_mail = Dir.new('/tmp/fake-mailer').entries.sort.last
  File.read("/tmp/fake-mailer/#{@activation_mail}").should match(/Aktywacja_konta/)
end
