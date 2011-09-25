!SLIDE bullets incremental
# Bootstrap
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

!SLIDE commandline 
# Bootstrap

    $ bin/fullstop --help
    Usage: fullstop [options]
    $ rake test
    Started
    .
    Finished in 0.000548 seconds.

    1 tests, 1 assertions, 0 failures, 0 errors, 0 skips

    Test run options: --seed 5857
    $ rake features
    ...

    1 scenario (1 passed)
    3 steps (3 passed)
    0m0.126s
    

!SLIDE smaller
# Let's add a feature

    @@@ Cucumber
    Feature: Install my dotfiles
      In order to set up a new user account quickly
      As a developer with his dotfiles in git
      I should be able to maintain them easily

      Scenario: Symlink my dotfiles
        Given I have my dotfiles in a git at "/tmp/testdotfiles"
        When I successfully run `fullstop /tmp/testdotfiles`
        Then my dotfiles should be checked out as "dotfiles" 
          in my home directory
        And my dotfiles should be symlinked in my home directory
_01_

!SLIDE commandline incremental smaller

    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/01)
    Feature: Install my dotfiles
      In order to set up a new user account quickly
      As a developer with his dotfiles in git
      I should be able to maintain them easily

      Scenario: Symlink my dotfiles
        Given I have my dotfiles in a git at "/tmp/testdotfiles"
        When I successfully run `fullstop /tmp/testdotfiles`
        Then my dotfiles should be checked out as "dotfiles" in my home directory
        And my dotfiles should be symlinked in my home directory

    1 scenario (1 undefined)
    4 steps (1 skipped, 3 undefined)
    0m0.007s

    You can implement step definitions for undefined steps with these snippets:

    Given /^I have my dotfiles in a git at "([^"]*)"$/ do |arg1|
      pending # express the regexp above with the code you wish you had
    end

    Then /^my dotfiles should be checked out as "([^"]*)" in my home directory$/ do |arg1|
      pending # express the regexp above with the code you wish you had
    end

    Then /^my dotfiles should be symlinked in my home directory$/ do
      pending # express the regexp above with the code you wish you had
    end

!SLIDE
# Implement these steps

!SLIDE smaller
    @@@Ruby
    require 'fileutils'

    include FileUtils

    FILES = %w(.bashrc .inputrc .vimrc)

    Given /^I have my dotfiles in a git at "(.*)"$/ do |git_repo|
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

!SLIDE smaller
    @@@Ruby
    Then 
      /^my dotfiles should be symlinked in my home directory$/ do
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
## `expected symlink? to return true, got false (RSpec::Expectations::ExpectationNotMetError)`
* Weaksauce
* We deserve a better message

!SLIDE smaller

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

!SLIDE commandline  smaller

    $ rake features
        Given I have my dotfiles in a git at "/tmp/testdotfiles"
        When I successfully run `fullstop /tmp/testdotfiles`
        Then my dotfiles should be checked out as "dotfiles" in my home directory
          expected file?("/Users/davec/dotfiles/.bashrc") to return true, got false (RSpec::Expectations::ExpectationNotMetError)
          features/fullstop.feature:9:in `Then my dotfiles should be checked out as "dotfiles" in my home directory'
        And my dotfiles should be symlinked in my home directory

    Failing Scenarios:
    cucumber features/fullstop.feature:6

    1 scenario (1 failed)
    4 steps (1 failed, 1 skipped, 2 passed)
    0m0.172s
    rake aborted!
    Cucumber failed

!SLIDE bullets incremental
## Then my dotfiles should be checked out as "dotfiles" in my home directory
* <span class="cuke-error">expected file?("/Users/davec/dotfiles/.bashrc") to return true, got false</span>
* Let's fix this
* And only this

!SLIDE smaller
    @@@Ruby
    #!/usr/bin/env ruby -w

    require 'optparse'
    

    

    option_parser = OptionParser.new do |opts|
    end

    option_parser.parse!

    
    #

!SLIDE smaller
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

!SLIDE small
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

    $ rake features
    Feature: Install my dotfiles
      In order to set up a new user account quickly
      As a developer with his dotfiles in git
      I should be able to maintain them easily

      Scenario: Symlink my dotfiles
        Given I have my dotfiles in a git at "/tmp/testdotfiles"
        When I successfully run `fullstop /tmp/testdotfiles`
        Then my dotfiles should be checked out as "dotfiles" in my home directory
        And my dotfiles should be symlinked in my home directory
          No such file or directory - /tmp/fakehome/.bashrc (Errno::ENOENT)
          ./features/step_definitions/fullstop_steps.rb:40:in `initialize'
          ./features/step_definitions/fullstop_steps.rb:40:in `open'
          ./features/step_definitions/fullstop_steps.rb:40:in `block (2 levels) in <top (required)>'
          ./features/step_definitions/fullstop_steps.rb:34:in `block (2 levels) in <top (required)>'
          ./features/step_definitions/fullstop_steps.rb:33:in `each'
          ./features/step_definitions/fullstop_steps.rb:33:in `/^my dotfiles should be symlinked in my home directory$/'
          features/fullstop.feature:10:in `And my dotfiles should be symlinked in my home directory'

    Failing Scenarios:
    cucumber features/fullstop.feature:6

    1 scenario (1 failed)
    4 steps (1 failed, 3 passed)
    0m0.184s
    rake aborted!
    Cucumber failed

!SLIDE  bullets incremental
# We got farther; fix the next problem
* "And my dotfiles should be symlinked in my home directory"
* <span class="cuke-error">No such file or directory - /tmp/fakehome/.bashrc (Errno::ENOENT)</span>

!SLIDE smaller

    @@@Ruby
    chdir ENV['HOME']
    %x[git clone #{ARGV[0]} dotfiles]

   



    
    #
_04_

!SLIDE smaller

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

!SLIDE commandline smaller
    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/04)
    Feature: Install my dotfiles
      In order to set up a new user account quickly
      As a developer with his dotfiles in git
      I should be able to maintain them easily

      Scenario: Symlink my dotfiles
        Given I have my dotfiles in a git at "/tmp/testdotfiles"
        When I successfully run `fullstop /tmp/testdotfiles`
        Then my dotfiles should be checked out as "dotfiles" in my home directory
        And my dotfiles should be symlinked in my home directory

    1 scenario (1 passed)
    4 steps (4 passed)

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

!SLIDE commandline smaller
    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/04)
    Feature: Install my dotfiles
      In order to set up a new user account quickly
      As a developer with his dotfiles in git
      I should be able to maintain them easily

      Scenario: Symlink my dotfiles
        Given I have my dotfiles in a git at "/tmp/testdotfiles"
        When I successfully run `fullstop /tmp/testdotfiles`
        Then my dotfiles should be checked out as "dotfiles" in my home directory
        And my dotfiles should be symlinked in my home directory

    1 scenario (1 passed)
    4 steps (4 passed)

!SLIDE bullets incremental
# We can now drive new features
## But what about:
* the UI? (it currently sucks)
* our complete lack of error handling?
