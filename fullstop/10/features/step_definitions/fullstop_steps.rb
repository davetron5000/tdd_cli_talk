require 'fileutils'

include FileUtils

def git(command,arg)
  command = "git #{command.to_s} #{arg}"
  %x[#{command}]
  raise "Error running #{command}" unless $?.success?
end

FILES = %w(.bashrc .inputrc .vimrc)
Given /^I have my dotfiles in git at "([^"]*)"$/ do |git_repo|
  raise "Watch out, /tmp only" unless git_repo =~ /\/tmp/
  
  rm_rf git_repo, :secure => true, :verbose => false if File.exists? git_repo
  mkdir_p git_repo
  chdir git_repo
  FILES.each { |file| touch file }
  git :init, '.'
  git :add, '.'
  git :commit, '-m "initial commit"'
end

Then /^my dotfiles should be checked out as "([^"]*)" in my home directory$/ do |dir|
  path = File.join(ENV['HOME'],dir)
  FILES.map{ |file| File.join(path,file) }.each do |file|
    step %(a file named "#{file}" should exist)
  end
end

Then /^my dotfiles should be symlinked in my home directory$/ do
  home = ENV['HOME']
  FILES.map { |file| File.join(home,file) }.each do |file|
    file.should be_a_symlink
  end
end

Then /^the output should not contain a backtrace$/ do
  step %(the output should not contain "<main>")
end

Given /^the file "([^"]*)" exists in my home directory$/ do |file|
  touch File.join(ENV['HOME'],file)
end

RSpec::Matchers.define :be_a_symlink do
  match do |actual|
    File.open(actual).lstat.symlink?
  end

  failure_message_for_should do |actual|
    "expected that #{actual} would be a symlink"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would NOT be a symlink"
  end

  description do
    "be a symlink"
  end
end


