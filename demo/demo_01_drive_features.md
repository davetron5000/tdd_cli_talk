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

!SLIDE small 
# Look at our code
    @@@ Ruby 
    #!/usr/bin/env ruby -w

    require 'optparse'

    option_parser = OptionParser.new do |opts|
      executable_name = File.basename(__FILE__)
      opts.banner = "Usage: #{executable_name} [options]"
    end

    option_parser.parse!

!SLIDE smaller
# Look at our gems

    @@@Ruby
    # -*- encoding: utf-8 -*-
    $:.push File.expand_path("../lib", __FILE__)
    require "fullstop/version"

    Gem::Specification.new do |s|
      s.name        = "fullstop"
      s.version     = Fullstop::VERSION
      s.authors     = ["Dave Copeland"]
      s.email       = ["davetron5000@gmail.com"]
      s.homepage    = ""
      s.summary     = %q{TODO: Write a gem summary}
      s.description = %q{TODO: Write a gem description}

      s.rubyforge_project = "fullstop"

      s.files         = `git ls-files`.split("\n")
      s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
      s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
      s.require_paths = ["lib"]
      s.add_development_dependency('rdoc')
      s.add_development_dependency('grancher')
      s.add_development_dependency('aruba')
    end

!SLIDE smaller
# Let's add a feature

    @@@ Cucumber
    Feature: Install my dotfiles
      As an organized developer who has his dotfiles on github
      I want to be able to set up a new user account easily

      Scenario: Symlink my dotfiles
        Given I have my dotfiles in a git repo at \
          "/Users/davec/Projects/testdotfiles"
        When I successfully run 
          `fullstop /Users/davec/Projects/testdotfiles"
        Then my dotfiles should be checked out in "~/dotfiles"
        And my dotfiles should be symlinked in "~/"
    

!SLIDE bullets incremental
# Uh-oh
* This is all in my home directory
* Developing on production

!SLIDE smaller
# Design for testability

    @@@ Cucumber
    Scenario: Symlink my dotfiles to an arbitrary directory
      Given an empty directory "/tmp/dotfiles"
      And I have my dotfiles in a git repo at \
        "/Users/davec/Projects/testdotfiles"
      When I successfully run \
        `fullstop /Users/davec/Projects/testdotfiles /tmp/dotfiles`
      Then my dotfiles should be checked out in \
        "/tmp/dotfiles/dotfiles"
      And my dotfiles should be symlinked in "/tmp/dotfiles"

!SLIDE
# Watch it fail
_cd 1 ; rake features_

!SLIDE commandline small
# Watch it fail

    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/1_first_feature)
    UU-UU

    1 scenario (1 undefined)
    5 steps (1 skipped, 4 undefined)
    0m0.009s

    You can implement step definitions for undefined steps with these snippets:

    Given /^an empty directory "([^"]*)"$/ do |arg1|
      pending # express the regexp above with the code you wish you had
    end

    Given /^I have my dotfiles at "([^"]*)"$/ do |arg1|
      pending # express the regexp above with the code you wish you had
    end

    Then /^my dotfiles should be checked out in "([^"]*)"$/ do |arg1|
      pending # express the regexp above with the code you wish you had
    end

    Then /^my dotfiles should be symlinked in "([^"]*)"$/ do |arg1|
      pending # express the regexp above with the code you wish you had
    end

!SLIDE smaller
# Make our tests not pend
## Given an empty directory

    @@@Ruby
    Given /^an empty directory "([^"]*)"$/ do |dir|
      unless File.split(dir)[0] == "/tmp"
        raise "Probably not what you want" 
      end
      rm_rf dir, :secure => true, :verbose => false
    end

!SLIDE smaller
# Make our tests not pend
## Given I have dotfiles in git

    @@@Ruby
    Given /^I have my dotfiles in a git repo at "([^"]*)"$/ do |repo|
      # no-op until we need the repo
    end

!SLIDE smaller
# Make our tests not pend
## Then my dotfiles should be checked out

    @@@Ruby
    Then /^my dotfiles should be checked out in "([^"]*)"$/ do |dir|
      ['.bashrc','.vimrc','.inputrc'].each do |file|
        Then %(a file named "#{File.join(dir,file)}" should exist)
      end
    end

!SLIDE smaller
# Make our tests not pend
## And they should be symlinked

    @@@Ruby
    Then /^my dotfiles should be symlinked in "([^"]*)"$/ do |dir|
      ['.bashrc','.vimrc','.inputrc'].each do |file|
        Then %(a file named "#{File.join(dir,file)}" should exist)
      end
    end
    

!SLIDE 
# Try it again

_(cd 2 ; rake features)_

!SLIDE commandline smaller 
# Try it again
    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/2)
    Feature: Install my dotfiles
      As an organized developer who has his dotfiles on github
      I want to be able to set up a new user account easily

      Scenario: Symlink my dotfiles to an arbitrary directory                               # features/fullstop.feature:5
        Given an empty directory "/tmp/dotfiles"                                            # features/step_definitions/fullstop_steps.rb:1
        And I have my dotfiles in a git repo at "/Users/davec/Projects/testdotfiles"        # features/step_definitions/fullstop_steps.rb:8
        When I successfully run `fullstop /Users/davec/Projects/testdotfiles /tmp/dotfiles` # aruba-0.4.6/lib/aruba/cucumber.rb:61
        Then my dotfiles should be checked out in "/tmp/dotfiles/dotfiles"                  # features/step_definitions/fullstop_steps.rb:12
          expected file?("/tmp/dotfiles/dotfiles/.bashrc") to return true, got false (RSpec::Expectations::ExpectationNotMetError)
          features/fullstop.feature:9:in `Then my dotfiles should be checked out in "/tmp/dotfiles/dotfiles"'
        And my dotfiles should be symlinked in "/tmp/dotfiles"                              # features/step_definitions/fullstop_steps.rb:18

    Failing Scenarios:
    cucumber features/fullstop.feature:5 # Scenario: Symlink my dotfiles to an arbitrary directory

    1 scenario (1 failed)
    5 steps (1 failed, 1 skipped, 3 passed)
    0m0.136s
    rake aborted!
    Cucumber failed

!SLIDE smaller
# Let's fix this 
## Initial

    @@@Ruby
    #!/usr/bin/env ruby -w

    require 'optparse'
    

    

    option_parser = OptionParser.new do |opts|
      executable_name = File.basename(__FILE__)
      opts.banner = "Usage: #{executable_name} [options]"
    end

    option_parser.parse!

    
    

    
    

    
    #

!SLIDE smaller
# Let's fix this 
## Fixed

    @@@Ruby
    #!/usr/bin/env ruby -w

    require 'optparse'
    require 'fileutils'

    include FileUtils

    option_parser = OptionParser.new do |opts|
      executable_name = File.basename(__FILE__)
      opts.banner = "Usage: #{executable_name} [options]"
    end

    option_parser.parse!

    repo = ARGV[0]
    checkout_dir = ARGV[1]

    mkdir_p checkout_dir
    chdir checkout_dir

    %x[git clone #{repo} dotfiles]
    #

!SLIDE 
# We got farther

_cd 3 ; rake features_

!SLIDE smaller commandline 
# We got farther

    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/3)
    Feature: Install my dotfiles
      As an organized developer who has his dotfiles on github
      I want to be able to set up a new user account easily

      Scenario: Symlink my dotfiles to an arbitrary directory                               # features/fullstop.feature:5
        Given an empty directory "/tmp/dotfiles"                                            # features/step_definitions/fullstop_steps.rb:1
        And I have my dotfiles in a git repo at "/Users/davec/Projects/testdotfiles"        # features/step_definitions/fullstop_steps.rb:8
        When I successfully run `fullstop /Users/davec/Projects/testdotfiles /tmp/dotfiles` # aruba-0.4.6/lib/aruba/cucumber.rb:61
        Then my dotfiles should be checked out in "/tmp/dotfiles/dotfiles"                  # features/step_definitions/fullstop_steps.rb:12
        And my dotfiles should be symlinked in "/tmp/dotfiles"                              # features/step_definitions/fullstop_steps.rb:18
          expected file?("/tmp/dotfiles/.bashrc") to return true, got false (RSpec::Expectations::ExpectationNotMetError)
          features/fullstop.feature:10:in `And my dotfiles should be symlinked in "/tmp/dotfiles"'

    Failing Scenarios:
    cucumber features/fullstop.feature:5 # Scenario: Symlink my dotfiles to an arbitrary directory

    1 scenario (1 failed)
    5 steps (1 failed, 4 passed)
    0m0.136s
    rake aborted!
    Cucumber failed

    (See full trace by running task with --trace)
    
   
!SLIDE smaller
# OK, fix THIS
## Where we are

    @@@Ruby

    # ...

    option_parser.parse!

    repo = ARGV[0]
    checkout_dir = ARGV[1]

    mkdir_p checkout_dir
    chdir checkout_dir

    %x[git clone #{repo} dotfiles]







    #

!SLIDE smaller
# OK, fix THIS
## Fixed

    @@@Ruby

    # ...

    option_parser.parse!

    repo = ARGV[0]
    checkout_dir = ARGV[1]

    mkdir_p checkout_dir
    chdir checkout_dir

    %x[git clone #{repo} dotfiles]

    Dir["#{checkout_dir}/dotfiles/{*,.*}"].each do |file|
      basename = File.basename(file)
      if basename != '.' && basename != '..'
        ln file,'.'
      end
    end
    #

!SLIDE 
# Feature done?

_cd 4; rake features_

!SLIDE commandline
# Feature done.

    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/1_first_feature)
    .....

    1 scenario (1 passed)
    5 steps (5 passed)
    0m0.331s

!SLIDE bullets incremental
# Refactor
* Big procedural blob
* Option parsing boilerplate up front
* Nasty `Dir[]` expression

!SLIDE 
# Outline of ideal app

    @@@Ruby
    #!/usr/bin/env ruby -w
    require 'optparse'
    require 'fileutils'

    include FileUtils

    # main logic
    # supplemental methods
    # UI setup
    # parse command-line and go!

!SLIDE 
# main logic

    @@@Ruby
    def main(repo,checkout_dir)
      mkdir_p checkout_dir
      chdir checkout_dir

      %x[git clone #{repo} dotfiles]

      dotfiles_in(checkout_dir) do |file| 
        ln file,'.'
      end
    end

!SLIDE small
# supplemental methods

    @@@Ruby
    def dotfiles_in(dir)
      Dir["#{dir}/dotfiles/{*,.*}"].each do |file|
        basename = File.basename(file)
        if basename != '.' && basename != '..'
          yield file
        end
      end
    end

!SLIDE small
# UI setup

    @@@ Ruby
    option_parser = OptionParser.new do |opts|
      executable_name = File.basename(__FILE__)
      opts.banner = "Usage: #{executable_name} [options]"
    end

!SLIDE
# parse command-line and go!

    @@@Ruby
    option_parser.parse!

    repo = ARGV[0]
    checkout_dir = ARGV[1]

    main(repo,checkout_dir)

!SLIDE
# We still want `~` to be default

!SLIDE smaller
# We still want `~` to be default

    @@@Cucumber
    Scenario: It should install into my home directory by default
      Given I have my dotfiles in a git repo at \
          "/Users/davec/Projects/testdotfiles"
      When I successfully run \
          `fullstop /Users/davec/Projects/testdotfiles`
      Then my dotfiles should be checked out \
          in "dotfiles" in my home directory
      And my dotfiles should be symlinked in my home directory

!SLIDE bullets incremental
# Don't forget:
## We're on production
* "in my home directory" vs "~"

!SLIDE small
# Change where $HOME is
## `features/support/env.rb`
    @@@ Ruby
    FAKE_HOME = '/tmp/fakehome'

    Before do
      @real_home = ENV['HOME']
      ENV['HOME'] = '/tmp/fakehome'
      rm_rf FAKE_HOME, :secure => true, :verbose => false
      mkdir FAKE_HOME, :verbose => false
    end

    After do
      ENV['HOME'] = @real_home
    end
    
!SLIDE smaller
# Implement new steps

    @@@Ruby
    Then /^my dotfiles should be checked out in 
          "([^"]*)" in my home directory$/ do |dir|
      Then %(my dotfiles should be checked out in 
             "#{File.join(ENV['HOME'],dir)}")
    end

    Then /^my dotfiles should be symlinked in 
           my home directory$/ do
      Then %(my dotfiles should be symlinked in 
             "#{ENV['HOME']}")
    end

!SLIDE
# Go

_cd 6; rake features_

!SLIDE smaller commandline 

    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/6)
    Feature: Install my dotfiles
      As an organized developer who has his dotfiles on github
      I want to be able to set up a new user account easily

      Scenario: Symlink my dotfiles to an arbitrary directory
        Given an empty directory "/tmp/dotfiles"
        And I have my dotfiles in a git repo at "/Users/davec/Projects/testdotfiles"
        When I successfully run `fullstop /Users/davec/Projects/testdotfiles /tmp/dotfiles`
        Then my dotfiles should be checked out in "/tmp/dotfiles/dotfiles"
        And my dotfiles should be symlinked in "/tmp/dotfiles"

      Scenario: It should install into my home directory by default
        Given I have my dotfiles in a git repo at "/Users/davec/Projects/testdotfiles"
        When I successfully run `fullstop /Users/davec/Projects/testdotfiles`
          Exit status was 1 but expected it to be 0. Output:
          
          /Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:1416:in `path': can't convert nil into String (TypeError)
            from /Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:1416:in `block in fu_list'
            from /Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:1416:in `map'
            from /Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:1416:in `fu_list'
            from /Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:197:in `mkdir_p'
            from /Users/davec/Projects/tdd_talk/fullstop/6/bin/fullstop:9:in `main'
            from /Users/davec/Projects/tdd_talk/fullstop/6/bin/fullstop:36:in `<main>'
          
           (RSpec::Expectations::ExpectationNotMetError)
          features/fullstop.feature:14:in `When I successfully run `fullstop /Users/davec/Projects/testdotfiles`'
        Then my dotfiles should be checked out in "dotfiles" in my home directory
        And my dotfiles should be symlinked in my home directory

    Failing Scenarios:
    cucumber features/fullstop.feature:12

    2 scenarios (1 failed, 1 passed)
    9 steps (1 failed, 2 skipped, 6 passed)
    0m0.259s
    rake aborted!
    Cucumber failed


!SLIDE smaller
# Fix

    @@@Ruby
    def main(repo,checkout_dir)

      mkdir_p checkout_dir
      chdir checkout_dir

      %x[git clone #{repo} dotfiles]

      dotfiles_in(checkout_dir) { |file| ln file,'.' }
    end

!SLIDE smaller
# Fix

    @@@Ruby
    def main(repo,checkout_dir)
      checkout_dir = ENV['HOME'] if checkout_dir.nil?
      mkdir_p checkout_dir
      chdir checkout_dir

      %x[git clone #{repo} dotfiles]

      dotfiles_in(checkout_dir) { |file| ln file,'.' }
    end

    
    

!SLIDE 
# Look at all that green!

!SLIDE  commandline smaller
# Look at all that green!

    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/7)
    Feature: Install my dotfiles
      As an organized developer who has his dotfiles on github
      I want to be able to set up a new user account easily

      Scenario: Symlink my dotfiles to an arbitrary directory
        Given an empty directory "/tmp/dotfiles"
        And I have my dotfiles in a git repo at "/Users/davec/Projects/testdotfiles"
        When I successfully run `fullstop /Users/davec/Projects/testdotfiles /tmp/dotfiles`
        Then my dotfiles should be checked out in "/tmp/dotfiles/dotfiles"
        And my dotfiles should be symlinked in "/tmp/dotfiles"

      Scenario: It should install into my home directory by default
        Given I have my dotfiles in a git repo at "/Users/davec/Projects/testdotfiles"
        When I successfully run `fullstop /Users/davec/Projects/testdotfiles`
        Then my dotfiles should be checked out in "dotfiles" in my home directory
        And my dotfiles should be symlinked in my home directory

    2 scenarios (2 passed)
    9 steps (9 passed)
    0m0.260s


!SLIDE bullets incremental
# Refactor?
* Not this time

!SLIDE bullets incremental
# So, we can test drive new features
## But what about:
* the UI? (it currently sucks)
* our complete lack of error handling?
