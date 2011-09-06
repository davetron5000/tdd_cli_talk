Given /^an empty directory "([^"]*)"$/ do |dir|
  unless File.split(dir)[0] == "/tmp"
    raise "Probably not what you want" 
  end
  rm_rf dir, :secure => true, :verbose => false
end

Given /^I have my dotfiles in a git repo at "([^"]*)"$/ do |repo|
  # no-op until we need the repo
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
