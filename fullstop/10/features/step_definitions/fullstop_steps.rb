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

Given /^the name of the app is "([^"]*)"$/ do |app_name|
  @app_name = app_name
end

Then /^it should have a banner$/ do
  Then %(the output should match /^Usage: #{@app_name}.*$/)
end

Then /^the banner should indicate that there are no options$/ do
  Then %(the output should not contain "[options]")
end

Then /^the banner should document the arguments as:$/ do |table|
  argument_string = table.raw.map { |row|
    option = row[0]
    option = "[#{row[0]}]" unless row[1] == 'which is required'
    option
  }.join(' ')
  Then %(the output should contain "#{argument_string}")
end

Then /^there should be a one\-line summary of what the app does$/ do
  output_lines = all_output.split(/\n/)
  output_lines.should have_at_least(3).items
  # [0] is our usage, which we've checked for
  output_lines[1].should match(/^\s*$/)
  output_lines[2].should match(/^\w+\s+\w+/)
end
