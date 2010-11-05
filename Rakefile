require "rubygems"
require "cucumber"
require "cucumber/rake/task"
require "rspec/core/rake_task"

task :default => [:features, :rspec]

Cucumber::Rake::Task.new(:features)
RSpec::Core::RakeTask.new(:rspec)
