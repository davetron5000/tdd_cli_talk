include FileUtils

Given /^an empty directory "([^"]*)"$/ do |dir|
  raise "Probably not what you want" unless File.split(dir)[0] == "/tmp"
  rm_rf dir, :secure => true, :verbose => false
end

Given /^I have my dotfiles at "([^"]*)"$/ do |repo|
  @dotfiles_repo = repo
end

Then /^my dotfiles should be checked out in "([^"]*)"$/ do |dir|
  ['.bashrc','.vimrc','.inputrc'].each do |file|
    Then %(a file named "#{File.join(dir,file)}" should exist)
  end
end

Then /^my dotfiles should be symlinked in "([^"]*)"$/ do |dir|
  ['.bashrc','.vimrc','.inputrc'].each do |file|
    Then %(a file named "#{File.join(dir,file)}" should exist)
  end
end

Then /^my dotfiles should be checked out in "([^"]*)" in my home directory$/ do |dir|
  Then %(my dotfiles should be checked out in "#{File.join(ENV['HOME'],dir)}")
end

Then /^my dotfiles should be symlinked in my home directory$/ do
  Then %(my dotfiles should be symlinked in "#{ENV['HOME']}")
end

Then /^there should be a banner$/ do
  Then %(the output should contain "Usage: fullstop")
end

Then /^the banner should not include options$/ do
  Then %(the output should not contain "[options]")
end

Then /^the banner should document that the arguments are "([^"]*)"$/ do |args|
  Then %(the output should contain "#{args}")
end
