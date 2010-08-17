Then /I should receive activation email/ do
  activation_mail = (Dir.new('/tmp/fake-mailer').entries - @received_mails).first
  File.read("/tmp/fake-mailer/#{activation_mail}").should match(/Aktywacja_konta/)
end
