!SLIDE bullets incremental
# Getting Started
* `mkdir fullstop`?
* `bundle gem fullstop`?

!SLIDE bullets incremental
# Step 0: Bootstrap
* 0 to running tests ASAP
* Reduces friction
* Enables and encourages

!SLIDE commandline small incremental
# Bootstrap


    $ methadone fullstop
    # => basic gemified project
    $ bundle install
    Fetching source index for http://rubygems.org/
    Using rack (1.3.2) 
    Installing bcat (0.6.1) 
    Installing ffi (1.0.9) with native extensions 
    Installing childprocess (0.2.2) 
    Installing builder (3.0.0) 
    Installing diff-lcs (1.1.2) 
    Using json (1.5.3) 
    Installing gherkin (2.4.16) with native extensions 
    Installing term-ansicolor (1.0.6) 
    Installing cucumber (1.0.2) 
    Installing rdiscount (1.6.8) with native extensions 
    Installing rspec-core (2.6.4) 
    Installing rspec-expectations (2.6.0) 
    Installing rspec-mocks (2.6.0) 
    Installing rspec (2.6.0) 
    Installing aruba (0.4.6) 
    Using fullstop (0.0.1) from source at /Users/davec/Projects/tdd_talk/fullstop/bootstrap 
    Installing open4 (0.9.6) 
    Installing gash (0.1.3) 
    Installing grancher (0.1.5) 
    Installing rdoc (3.9.4) 
    Using bundler (1.0.15) 
    Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.

!SLIDE commandline 
# Bootstrap

    $ bin/fullstop --help

!SLIDE commandline incremental small
# Bootstrap

    $ bin/fullstop --help</em>
    Usage: fullstop [options]

!SLIDE code small
# Bootstrap

<pre style="font-size: 22px;">
<em>$ rake test</em>
Started
.
Finished in 0.000395 seconds.

1 tests, 1 assertions, 0 failures, 0 errors, 0 skips

Test run options: --seed 19867
Feature: My bootstrapped app kinda works
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself

  Scenario: App just runs
    <span class="ansi-32">When I get help for "<span class="ansi-1">fullstop</span>"
    Then the exit status should be 0
    And the banner should be present
    And the banner should document that this app takes options
    And the following options should be documented:
      | --version |
    And the banner should document that this app takes no arguments</span>

1 scenario (<span class="ansi-32">1 passed</span>)
6 steps (<span class="ansi-32">6 passed</span>)
0m0.248s
</pre> 
    

!SLIDE smaller
# Let's add a feature

    @@@ Cucumber
    Feature: Install my dotfiles
      In order to set up a new user account quickly
      As a developer with his dotfiles in git
      I should be able to maintain them easily

      Scenario: Symlink my dotfiles
        Given I have my dotfiles in git at "/tmp/testdotfiles"
        When I successfully run `fullstop /tmp/testdotfiles`
        Then my dotfiles should be checked out as "dotfiles" 
          in my home directory
        And my dotfiles should be symlinked in my home directory
_01_

!SLIDE bullets incremental
# Aruba
* Cucumber Steps for command-line
* "When I run..."
* "Then the exit status should not be 0"
* "Then the stderr should contain..."
* etc.


!SLIDE code small

<pre style="font-size: 20px">
<em>$ rake features</em>
Feature: Install my dotfiles
  In order to set up a new user account quickly
  As a developer with his dotfiles in git
  I should be able to maintain them easily

  Scenario: Symlink my dotfiles
    <span class='ansi-33'>Given I have my dotfiles in git at "/tmp/testdotfiles"<span class='ansi-0'></span></span>
    <span class='ansi-36'>When I successfully run `<span class='ansi-36'><span class='ansi-1'>fullstop /tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-36'>`<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-33'>Then my dotfiles should be checked out as "dotfiles" in my home directory<span class='ansi-0'></span></span>
    <span class='ansi-33'>And my dotfiles should be symlinked in my home directory<span class='ansi-0'></span></span>

1 scenario (<span class='ansi-33'>1 undefined<span class='ansi-0'>)</span></span>
4 steps (<span class='ansi-36'>1 skipped<span class='ansi-0'>, <span class='ansi-33'>3 undefined<span class='ansi-0'>)</span></span></span></span>
0m0.006s
<span class='ansi-33'><span class='ansi-0'></span></span>
<span class='ansi-33'>You can implement step definitions for undefined steps with these snippets:<span class='ansi-0'></span></span>
<span class='ansi-33'><span class='ansi-0'></span></span>
<span class='ansi-33'>Given /^I have my dotfiles in git at "(.*?)"$/ do |arg1|<span class='ansi-0'></span></span>
<span class='ansi-33'>  pending # express the regexp above with the code you wish you had<span class='ansi-0'></span></span>
<span class='ansi-33'>end<span class='ansi-0'></span></span>
<span class='ansi-33'><span class='ansi-0'></span></span>
<span style="font-size: 94%;"><span class='ansi-33'>Then /^my dotfiles should be checked out as "(.*?)" in my home directory$/ do |arg1|<span class='ansi-0'></span></span></span>
<span class='ansi-33'>  pending # express the regexp above with the code you wish you had<span class='ansi-0'></span></span>
<span class='ansi-33'>end<span class='ansi-0'></span></span>
<span class='ansi-33'><span class='ansi-0'></span></span>
<span class='ansi-33'>Then /^my dotfiles should be symlinked in my home directory$/ do<span class='ansi-0'></span></span>
<span class='ansi-33'>  pending # express the regexp above with the code you wish you had<span class='ansi-0'></span></span>
<span class='ansi-33'>end<span class='ansi-0'></span></span>
</pre>

!SLIDE
# Implement these steps

!SLIDE smaller
    @@@Ruby
    require 'fileutils'

    include FileUtils

    FILES = %w(.bashrc .inputrc .vimrc)

    Given /^I have my dotfiles in git at "(.*)"$/ do |git_repo|
      rm_rf git_repo, :secure => true if File.exists? git_repo
      mkdir_p git_repo
      chdir git_repo

      FILES.each { |file| touch file }

      git :init,   '.'
      git :add,    '.'
      git :commit, '-m "initial commit"'
    end
    
    def git(command,arg)
      command = "git #{command.to_s} #{arg}"
      %x[#{command}]
      raise "Error running #{command}" unless $?.success?
    end


!SLIDE smaller

    @@@Ruby
    Then /^my dotfiles should be checked out as "([^"]*)" 
           in my home directory$/ do |dir|
      path = File.join(ENV['HOME'],dir)
      FILES.map{ |file| File.join(path,file) }.each do |file|
        Then %(a file named "#{file}" should exist)
      end
    end

!SLIDE smaller1
    @@@Ruby
    Then /^my dotfiles should be symlinked in my home directory$/ do
      FILES.map { |file| 
        File.join(ENV['HOME'],file) 
      }.each do |file|
        file.should be_a_symlink
      end
    end


!SLIDE
# Quick aside

    @@@Ruby
    File.new(file).lstat.should be_symlink

!SLIDE bullets incremental
### `expected symlink? to return true, got false (RSpec::Expectations::ExpectationNotMetError)`
* Weaksauce
* We deserve a better message

!SLIDE small1

    @@@Ruby
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
        
!SLIDE
# NOW do we have a failing test?

_02_

!SLIDE code
# `rake features`
<pre style="font-size: 20px">
Feature: Install my dotfiles
  In order to set up a new user account quickly
  As a developer with his dotfiles in git
  I should be able to maintain them easily

  Scenario: Symlink my dotfiles
    <span class='ansi-32'>Given I have my dotfiles in git at "<span class='ansi-32'><span class='ansi-1'>/tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
rake aborted!
Cucumber failed

Tasks: TOP => features
(See full trace by running task with --trace)
    <span class='ansi-32'>When I successfully run `<span class='ansi-32'><span class='ansi-1'>fullstop /tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>`<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-31'>Then my dotfiles should be checked out as "<span class='ansi-31'><span class='ansi-1'>dotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-31'>" in my home directory<span class='ansi-0'></span></span></span></span></span></span></span>
<span class='ansi-31'>      expected file?("/Users/davec/dotfiles/.bashrc") to return true, got false (RSpec::Expectations::ExpectationNotMetError)<span class='ansi-0'></span></span>
<span class='ansi-31'>      features/fullstop.feature:9:in `Then my dotfiles should be checked out as "dotfiles" in my home directory'<span class='ansi-0'></span></span>
    <span class='ansi-36'>And my dotfiles should be symlinked in my home directory<span class='ansi-0'></span></span>

<span class='ansi-31'>Failing Scenarios:<span class='ansi-0'></span></span>
<span class='ansi-31'>cucumber features/fullstop.feature:6<span class='ansi-0'></span></span>

1 scenario (<span class='ansi-31'>1 failed<span class='ansi-0'>)</span></span>
4 steps (<span class='ansi-31'>1 failed<span class='ansi-0'>, <span class='ansi-36'>1 skipped<span class='ansi-0'>, <span class='ansi-32'>2 passed<span class='ansi-0'>)</span></span></span></span></span></span>
0m0.164s
</pre>
    

!SLIDE bullets incremental
## Then my dotfiles should be checked out as "dotfiles" in my home directory
* <span class="cuke-error">expected file?("/Users/davec/dotfiles/.bashrc") to return true, got false</span>
* Let's fix this
* And only this

!SLIDE 
    @@@Ruby
    #!/usr/bin/env ruby -w

    require 'optparse'
    

    

    option_parser = OptionParser.new do |opts|
    end

    option_parser.parse!

    
    #

!SLIDE
    @@@Ruby
    #!/usr/bin/env ruby -w

    require 'optparse'
    require 'fileutils'

    include FileUtils

    option_parser = OptionParser.new do |opts|
    end

    option_parser.parse!

    chdir ENV['HOME']
    %x[git clone #{ARGV[0]} dotfiles]

!SLIDE bullets incremental
# Uh-oh
* `ENV['HOME']`
* `cd /Users/davec && git clone /tmp/testdotfiles dotfiles`

!SLIDE
# We are developing on production

!SLIDE small2
# Change `ENV['HOME']` 

    @@@Ruby
    Before do
      @real_home = ENV['HOME']
      fake_home = File.join('/tmp','fakehome')
      rm_rf fake_home if File.exists? fake_home
      mkdir_p fake_home
      ENV['HOME'] = fake_home
    end

    After do
      ENV['HOME'] = @real_home
    end

!SLIDE
# Whew!

_03_

!SLIDE commandline smaller
# `$ rake features`
<pre style="font-size: 20px">
Feature: Install my dotfiles
  In order to set up a new user account quickly
  As a developer with his dotfiles in git
  I should be able to maintain them easily

  Scenario: Symlink my dotfiles
    <span class='ansi-32'>Given I have my dotfiles in git at "<span class='ansi-32'><span class='ansi-1'>/tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
rake aborted!
Cucumber failed

Tasks: TOP => features
(See full trace by running task with --trace)
    <span class='ansi-32'>When I successfully run `<span class='ansi-32'><span class='ansi-1'>fullstop /tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>`<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>Then my dotfiles should be checked out as "<span class='ansi-32'><span class='ansi-1'>dotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>" in my home directory<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-31'>And my dotfiles should be symlinked in my home directory<span class='ansi-0'></span></span>
<span class='ansi-31'>      No such file or directory - /tmp/fakehome/.bashrc (Errno::ENOENT)<span class='ansi-0'></span></span>
<span class='ansi-31'>      ./features/step_definitions/fullstop_steps.rb:40:in `initialize'<span class='ansi-0'></span></span>
<span class='ansi-31'>      ./features/step_definitions/fullstop_steps.rb:40:in `open'<span class='ansi-0'></span></span>
<span class='ansi-31'>      ./features/step_definitions/fullstop_steps.rb:40:in `block (2 levels) in <top (required)>'<span class='ansi-0'></span></span>
<span class='ansi-31'>      ./features/step_definitions/fullstop_steps.rb:34:in `block (2 levels) in <top (required)>'<span class='ansi-0'></span></span>
<span class='ansi-31'>      ./features/step_definitions/fullstop_steps.rb:33:in `each'<span class='ansi-0'></span></span>
<span class='ansi-31'>      ./features/step_definitions/fullstop_steps.rb:33:in `/^my dotfiles should be symlinked in my home directory$/'<span class='ansi-0'></span></span>
<span class='ansi-31'>      features/fullstop.feature:10:in `And my dotfiles should be symlinked in my home directory'<span class='ansi-0'></span></span>

<span class='ansi-31'>Failing Scenarios:<span class='ansi-0'></span></span>
<span class='ansi-31'>cucumber features/fullstop.feature:6<span class='ansi-0'></span></span>

1 scenario (<span class='ansi-31'>1 failed<span class='ansi-0'>)</span></span>
4 steps (<span class='ansi-31'>1 failed<span class='ansi-0'>, <span class='ansi-32'>3 passed<span class='ansi-0'>)</span></span></span></span>
0m0.173s
</pre>

!SLIDE  bullets incremental
# We got farther
## Fix the next problem
* "And my dotfiles should be symlinked in my home directory"
* <span class="cuke-error">No such file or directory - /tmp/fakehome/.bashrc (Errno::ENOENT)</span>

!SLIDE small1

    @@@Ruby
    chdir ENV['HOME']
    %x[git clone #{ARGV[0]} dotfiles]

   



    
    #
_04_

!SLIDE small1

    @@@Ruby
    chdir ENV['HOME']
    %x[git clone #{ARGV[0]} dotfiles]

    Dir["#{ENV['HOME']}/dotfiles/{*,.*}"].each do |file|
      unless File.basename(file) == '.' || 
             File.basename(file) == '..'
        ln_s file,'.'
      end
    end

_04_

!SLIDE
# GREEN!

!SLIDE 
<pre style="font-size: 22px">
  Feature: Install my dotfiles
  In order to set up a new user account quickly
  As a developer with his dotfiles in git
  I should be able to maintain them easily

  Scenario: Symlink my dotfiles
    <span class='ansi-32'>Given I have my dotfiles in git at "<span class='ansi-32'><span class='ansi-1'>/tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>When I successfully run `<span class='ansi-32'><span class='ansi-1'>fullstop /tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>`<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>Then my dotfiles should be checked out as "<span class='ansi-32'><span class='ansi-1'>dotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>" in my home directory<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And my dotfiles should be symlinked in my home directory<span class='ansi-0'></span></span>

1 scenario (<span class='ansi-32'>1 passed<span class='ansi-0'>)</span></span>
4 steps (<span class='ansi-32'>4 passed<span class='ansi-0'>)</span></span>
0m0.168s
</pre>

!SLIDE bullets incremental
# Refactor
* **No** variables
* Horrible regexy `Dir` thing
* repetition
* Backwards organization

!SLIDE smaller
    @@@Ruby
    DOTFILES = 'dotfiles'

    def main(repo,link_dir)
      chdir link_dir
      %x[git clone #{repo} #{DOTFILES}]

      dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end














    #

!SLIDE smaller
    @@@Ruby
    DOTFILES = 'dotfiles'

    def main(repo,link_dir)
      chdir link_dir
      %x[git clone #{repo} #{DOTFILES}]

      dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

    def dotfiles_in(cloned_repo)
      Dir["#{cloned_repo}/{*,.*}"].reject { |file|
        %w(. ..).include? File.basename(file) 
      }.each do |file| 
        yield file
      end
    end






    #

!SLIDE smaller
    @@@Ruby
    DOTFILES = 'dotfiles'

    def main(repo,link_dir)
      chdir link_dir
      %x[git clone #{repo} #{DOTFILES}]

      dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

    def dotfiles_in(cloned_repo)
      Dir["#{cloned_repo}/{*,.*}"].reject { |file|
        %w(. ..).include? File.basename(file) 
      }.each do |file| 
        yield file
      end
    end

    option_parser = OptionParser.new do |opts|
    end

    option_parser.parse!

    main(ARGV[0],ENV['HOME'])

!SLIDE
# Is it a good refactor?
_05_

!SLIDE
<pre style="font-size: 22px">
  Feature: Install my dotfiles
  In order to set up a new user account quickly
  As a developer with his dotfiles in git
  I should be able to maintain them easily

  Scenario: Symlink my dotfiles
    <span class='ansi-32'>Given I have my dotfiles in git at "<span class='ansi-32'><span class='ansi-1'>/tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>When I successfully run `<span class='ansi-32'><span class='ansi-1'>fullstop /tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>`<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>Then my dotfiles should be checked out as "<span class='ansi-32'><span class='ansi-1'>dotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>" in my home directory<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And my dotfiles should be symlinked in my home directory<span class='ansi-0'></span></span>

1 scenario (<span class='ansi-32'>1 passed<span class='ansi-0'>)</span></span>
4 steps (<span class='ansi-32'>4 passed<span class='ansi-0'>)</span></span>
0m0.174s
</pre>

!SLIDE bullets incremental
# We can now drive new features
## But what about:
* the UI? (it currently sucks)
* our complete lack of error handling?
