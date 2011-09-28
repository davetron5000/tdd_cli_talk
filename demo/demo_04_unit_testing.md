!SLIDE
# First, we need units

!SLIDE
# Refactor

!SLIDE smaller
# `bin/fullstop`

    @@@Ruby
    require 'fileutils'

    
      include FileUtils
   
        DOTFILES = 'dotfiles'

        def      main(repo,link_dir)
          chdir link_dir
          %x[git clone #{repo} #{DOTFILES}]

          dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
            ln_s file,'.'
          end
        end

        def      dotfiles_in(cloned_repo)
          Dir["#{cloned_repo}/{*,.*}"].reject { |file|
            %w(. ..).include? File.basename(file) 
          }.each do |file| 
            yield file
          end
        end
      
    #

!SLIDE smaller
# `lib/fullstop/cli.rb`

    @@@Ruby
    require 'fileutils'

    module Fullstop
      include FileUtils
      class CLI
        DOTFILES = 'dotfiles'

        def self.main(repo,link_dir)
          chdir link_dir
          %x["git clone #{repo} #{DOTFILES}"]

          dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
            ln_s file,'.'
          end
        end

        def self.dotfiles_in(cloned_repo)
          Dir["#{cloned_repo}/{*,.*}"].reject { |file|
            %w(. ..).include? File.basename(file) 
          }.each do |file| 
            yield file
          end
        end
      end
    end

!SLIDE smaller
# `lib/fullstop/cli.rb`

    @@@Ruby
    require 'fileutils'

    module Fullstop
      include FileUtils
      class CLI
        DOTFILES = 'dotfiles'

        def self.main(repo,link_dir)
          chdir link_dir
          system("git clone #{repo} #{DOTFILES}")

          dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
            ln_s file,'.'
          end
        end

        def self.dotfiles_in(cloned_repo)
          Dir["#{cloned_repo}/{*,.*}"].reject { |file|
            %w(. ..).include? File.basename(file) 
          }.each do |file| 
            yield file
          end
        end
      end
    end

!SLIDE
# `bin/fullstop`

    @@@Ruby
    

    begin
          main(ARGV[0],ENV['HOME'])
    rescue Exception => ex
      STDERR.puts ex.message
      exit 1
    end

!SLIDE
# `bin/fullstop`

    @@@Ruby
    include Fullstop

    begin
      CLI.main(ARGV[0],ENV['HOME'])
    rescue Exception => ex
      STDERR.puts ex.message
      exit 1
    end

!SLIDE
# Is it good?
_10_

!SLIDE commandline smaller
    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/10)
    Feature: Install my dotfiles
      In order to set up a new user account quickly
      As a developer with his dotfiles in git
      I should be able to maintain them easily

      Scenario: Symlink my dotfiles
        Given I have my dotfiles in git at "/tmp/testdotfiles"
        When I successfully run `fullstop /tmp/testdotfiles`
        Then my dotfiles should be checked out as "dotfiles" in my home directory
        And my dotfiles should be symlinked in my home directory

      Scenario: The UI is not sucky
        When I get help for "fullstop"
        Then the exit status should be 0
        And the banner should be present
        And the banner should document that this app takes no options
        And the banner should document that this app's arguments are:
          | repo | which is required |
        And there should be a one line summary of what the app does

      Scenario: File already exists and cannot be symlinked
        Given I have my dotfiles in git at "/tmp/testdotfiles"
        And the file ".bashrc" exists in my home directory
        When I run `fullstop /tmp/testdotfiles`
        Then the exit status should not be 0
        And the stderr should contain "File exists"
        And the stderr should contain ".bashrc"
        And the output should not contain a backtrace

    3 scenarios (3 passed)
    17 steps (17 passed)
    0m0.477s


!SLIDE bullets incremental
# Approach
* Any problem...
* ...raise
* `bin/fullstop` already handles the UI

!SLIDE bullets incremental
# New test
* `FileUtils` methods throw exceptions
* `system` returns `true` or `false`

!SLIDE small
# Test
## Setup

    @@@Ruby
    include Fullstop
    def test_git_failure
      CLI.stubs(:chdir)
      CLI.stubs(:system).returns(false)
      CLI.stubs(:ln_s).raises(
              "Should not have been called")
      
     
    
   
  
    end

_11_

!SLIDE small
# Test
## Assertions

    @@@Ruby
    include Fullstop
    def test_git_failure_causes_exception
      CLI.stubs(:chdir)
      CLI.stubs(:system).returns(false)
      CLI.stubs(:ln_s).raises(
              "Should not have been called")
      ex = assert_raises RuntimeError do
        CLI.main('foo','foo')
      end
      assert_equal "'git clone foo dotfiles' failed",
                   ex.message
    end

_11_

!SLIDE commandline smaller

    $ rake test
    (in /Users/davec/Projects/tdd_talk/fullstop/11)
    Loaded suite /Users/davec/.rvm/gems/ruby-1.9.2-p290@global/gems/rake-0.8.7/lib/rake/rake_test_loader
    Started
    F
    Finished in 0.001077 seconds.

      1) Failure:
    test_git_failure_causes_exception(TestSomething) [test/tc_something.rb:11]:
    RuntimeError expected but nothing was raised.

    1 tests, 1 assertions, 1 failures, 0 errors, 0 skips

    Test run options: --seed 42302
    rake aborted!
    Command failed with status (1): [/Users/davec/.rvm/rubies/ruby-1.9.2-p290/b...]

!SLIDE smaller
# Fix

    @@@Ruby
    def self.main(repo,link_dir)
      chdir link_dir
      system("git clone #{repo} #{DOTFILES}")
      
      

      dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

_12_

!SLIDE smaller
# Fix

    @@@Ruby
    def self.main(repo,link_dir)
      chdir link_dir
      unless system("git clone #{repo} #{DOTFILES}")
        raise "'git clone #{repo} #{DOTFILES}' failed"
      end

      dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

_12_

!SLIDE commandline smaller
    $ rake test
    (in /Users/davec/Projects/tdd_talk/fullstop/12)
    Loaded suite /Users/davec/.rvm/gems/ruby-1.9.2-p290@global/gems/rake-0.8.7/lib/rake/rake_test_loader
    Started
    .
    Finished in 0.001149 seconds.

    1 tests, 2 assertions, 0 failures, 0 errors, 0 skips


!SLIDE smaller
# Refactor

    @@@Ruby
    def self.main(repo,link_dir)
      chdir link_dir
      unless system("git clone #{repo} #{DOTFILES}")
        raise "'git clone #{repo} #{DOTFILES}' failed"
      end

      dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

    

    #

_13_

!SLIDE smaller
# Refactor

    @@@Ruby
    def self.main(repo,link_dir)
      chdir link_dir
      sh! "git clone #{repo} #{DOTFILES}"

      dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

    def self.sh!(command)
      unless system(command)
        raise "'#{command}' failed"
      end
    end

_13_

!SLIDE commandline smaller
    $ rake test features
    (in /Users/davec/Projects/tdd_talk/fullstop/13)
    Loaded suite /Users/davec/.rvm/gems/ruby-1.9.2-p290@global/gems/rake-0.8.7/lib/rake/rake_test_loader
    Started
    .
    Finished in 0.001114 seconds.

    1 tests, 2 assertions, 0 failures, 0 errors, 0 skips

    Test run options: --seed 64493
    Feature: Install my dotfiles
      In order to set up a new user account quickly
      As a developer with his dotfiles in git
      I should be able to maintain them easily

      Scenario: Symlink my dotfiles
        Given I have my dotfiles in git at "/tmp/testdotfiles"
        When I successfully run `fullstop /tmp/testdotfiles`
        Then my dotfiles should be checked out as "dotfiles" in my home directory
        And my dotfiles should be symlinked in my home directory

      Scenario: The UI is not sucky
        When I get help for "fullstop"
        Then the exit status should be 0
        And the banner should be present
        And the banner should document that this app takes no options
        And the banner should document that this app's arguments are:
          | repo | which is required |
        And there should be a one line summary of what the app does

      Scenario: File already exists and cannot be symlinked
        Given I have my dotfiles in git at "/tmp/testdotfiles"
        And the file ".bashrc" exists in my home directory
        When I run `fullstop /tmp/testdotfiles`
        Then the exit status should not be 0
        And the stderr should contain "File exists"
        And the stderr should contain ".bashrc"
        And the output should not contain a backtrace

    3 scenarios (3 passed)
    17 steps (17 passed)
    0m0.476s

