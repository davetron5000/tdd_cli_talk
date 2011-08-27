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
