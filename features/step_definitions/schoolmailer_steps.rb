Then /I should receive activation email/ do
  @files_count.should_not eql(Dir.new('/tmp/fake-mailer').entries.size)
end
