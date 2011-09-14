!SLIDE subsection
# Unhappy Path

!SLIDE smaller

    @@@Ruby
    def main(repo,checkout_dir)
      checkout_dir = ENV['HOME'] if checkout_dir.nil?
      mkdir_p checkout_dir           ### What if this fails?
      chdir checkout_dir             ### What if THIS fails?

      %x[git clone #{repo} dotfiles] ### And THIS?

      dotfiles_in(checkout_dir) { |file| ln file,'.' }
    end

!SLIDE
# ???

    @@@Ruby
    if ENV['TESTING']
      include FaultyFileUtils
    else
      include FileUtils
    end

!SLIDE bullets incremental
# Um, no.
* Treat cuke tests as acceptance tests
* We could still benefit from unit tests

!SLIDE 
# First, let's get a testable unit

!SLIDE
# Refactor

!SLIDE smaller
    @@@Ruby
    require 'fileutils'


    
    

    
    

        def main(repo,checkout_dir)
          checkout_dir = ENV['HOME'] if checkout_dir.nil?
          mkdir_p checkout_dir
          chdir checkout_dir

          %x[git clone #{repo} dotfiles]

          dotfiles_in(checkout_dir) { |file| ln file,'.' }
        end

        def dotfiles_in(dir)
          Dir["#{dir}/dotfiles/{*,.*}"].each do |file|
            basename = File.basename(file)
            if basename != '.' && basename != '..'
              yield file
            end
          end
        end

    #

!SLIDE smaller
    @@@Ruby
    require 'fileutils'



    

    module Fullstop
      module CLI
        include FileUtils
        def main(repo,checkout_dir)
          checkout_dir = ENV['HOME'] if checkout_dir.nil?
          mkdir_p checkout_dir
          chdir checkout_dir

          %x[git clone #{repo} dotfiles]

          dotfiles_in(checkout_dir) { |file| ln file,'.' }
        end

        def dotfiles_in(dir)
          Dir["#{dir}/dotfiles/{*,.*}"].each do |file|
            basename = File.basename(file)
            if basename != '.' && basename != '..'
              yield file
            end
          end
        end
      end
    end


!SLIDE smaller

    @@@Ruby
    #!/usr/bin/env ruby -w

    $: << File.expand_path(File.dirname(File.realpath(__FILE__)) + 
          '/../lib') 

    require 'optparse'
    

    

    option_parser = OptionParser.new do |opts|
      executable_name = File.basename(__FILE__)
      opts.banner = "Usage: #{executable_name} dotfiles_repo [checkout_dir]
      
    fullstop manages symlinking your dotfiles from a git repo"
    end

    option_parser.parse!

    repo = ARGV[0]
    checkout_dir = ARGV[1]

    main(repo,checkout_dir)

!SLIDE smaller

    @@@Ruby
    #!/usr/bin/env ruby -w

    $: << File.expand_path(File.dirname(File.realpath(__FILE__)) + 
          '/../lib') 

    require 'optparse'
    require 'fullstop'

    include Fullstop::CLI

    option_parser = OptionParser.new do |opts|
      executable_name = File.basename(__FILE__)
      opts.banner = "Usage: #{executable_name} dotfiles_repo [checkout_dir]
      
    fullstop manages symlinking your dotfiles from a git repo"
    end

    option_parser.parse!

    repo = ARGV[0]
    checkout_dir = ARGV[1]

    main(repo,checkout_dir)

!SLIDE
# Did we break anything?

_cd 11 && rake features_

!SLIDE commandline smaller
# Did we break anything?
    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/11)
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

      Scenario: The UI should be good
        Given the name of the app is "fullstop"
        When I run `fullstop --help`
        Then it should have a banner
        And the banner should indicate that there are no options
        And the banner should document the arguments as:
          | dotfiles_repo | required |
          | checkout_dir  | optional |
        And there should be a one-line summary of what the app does

    3 scenarios (3 passed)
    15 steps (15 passed)
    0m0.393s

!SLIDE bullets incremental
# Still green; now what?
* What if our `mkdir_p` fails?

!SLIDE bullets incremental
# `mkdir_p`
* Throws Exceptions on failure
* Those Exceptions are not documented

!SLIDE bullets incremental
# How to Simulate?
* Mock filesystem?
* Set up our own FS in `/tmp` ?

!SLIDE bullets incremental
# Mock code
* We `include FileUtils`
* we can mock/stub `mkdir_p`

!SLIDE smaller
# Setup

    @@@Ruby
    require 'minitest/autorun'
    require 'fullstop'
    require 'mocha'

    class TestCLI < MiniTest::Unit::TestCase
      class Tester
        include Fullstop::CLI
      end

      def test_that_inability_to_make_checkout_dir_causes_exception
        tester = Tester.new
        repo = File.join(ENV['HOME'],'dotfiles.git')

        tester.stubs(:mkdir_p).throws(RuntimeError)






      end
    end

!SLIDE smaller
# Assertions

    @@@Ruby
    require 'minitest/autorun'
    require 'fullstop'
    require 'mocha'

    class TestCLI < MiniTest::Unit::TestCase
      class Tester
        include Fullstop::CLI
      end

      def test_that_inability_to_make_checkout_dir_causes_exception
        tester = Tester.new
        repo = File.join(ENV['HOME'],'dotfiles.git')

        tester.stubs(:mkdir_p).throws(RuntimeError)

        ex = assert_raises RuntimeError do
          tester.main(repo,nil)
        end
        assert_equal ("Problem creating directory #{ENV['HOME']}", 
                      ex.message)
      end
    end

!SLIDE
# Test

_cd 12; rake test_

!SLIDE commandline smaller
# Test

    $ rake test
    (in /Users/davec/Projects/tdd_talk/fullstop/12)
    Loaded suite /Users/davec/.rvm/gems/ruby-1.9.2-p290@global/gems/rake-0.8.7/lib/rake/rake_test_loader
    Started
    F
    Finished in 0.001835 seconds.

      1) Failure:
    test_that_inability_to_make_checkout_dir_causes_exception(TestCLI) [test/tc_cli.rb:23]:
    [RuntimeError] exception expected, not
    Class: <ArgumentError>
    Message: <"uncaught throw RuntimeError">
    ---Backtrace---
    /Users/davec/.rvm/gems/ruby-1.9.2-p290@tdd-cli/gems/mocha-0.10.0/lib/mocha/thrower.rb:10:in `throw'
    /Users/davec/.rvm/gems/ruby-1.9.2-p290@tdd-cli/gems/mocha-0.10.0/lib/mocha/thrower.rb:10:in `evaluate'
    /Users/davec/.rvm/gems/ruby-1.9.2-p290@tdd-cli/gems/mocha-0.10.0/lib/mocha/return_values.rb:20:in `next'
    /Users/davec/.rvm/gems/ruby-1.9.2-p290@tdd-cli/gems/mocha-0.10.0/lib/mocha/expectation.rb:472:in `invoke'
    /Users/davec/.rvm/gems/ruby-1.9.2-p290@tdd-cli/gems/mocha-0.10.0/lib/mocha/mock.rb:157:in `method_missing'
    /Users/davec/.rvm/gems/ruby-1.9.2-p290@tdd-cli/gems/mocha-0.10.0/lib/mocha/class_method.rb:46:in `mkdir_p'
    /Users/davec/Projects/tdd_talk/fullstop/12/lib/fullstop/cli.rb:8:in `main'
    test/tc_cli.rb:24:in `block in test_that_inability_to_make_checkout_dir_causes_exception'
    test/tc_cli.rb:32:in `block in assert_raises_with_message'
    ---------------

    1 tests, 1 assertions, 1 failures, 0 errors, 0 skips

    Test run options: --seed 54132
    rake aborted!
    Command failed with status (1): [/Users/davec/.rvm/rubies/ruby-1.9.2-p290/b...]

    (See full trace by running task with --trace)

!SLIDE small
# Fix

    @@@Ruby
    def main(repo,checkout_dir)
      checkout_dir = ENV['HOME'] if checkout_dir.nil?

      
      mkdir_p checkout_dir
      
      
      
      chdir checkout_dir

      %x[git clone #{repo} dotfiles]

      dotfiles_in(checkout_dir) do |file| 
        ln file,'.'
      end
    end

!SLIDE small
# Fix

    @@@Ruby
    def main(repo,checkout_dir)
      checkout_dir = ENV['HOME'] if checkout_dir.nil?

      begin
        mkdir_p checkout_dir
      rescue
        raise "Problem creating directory #{checkout_dir}"
      end
      chdir checkout_dir

      %x[git clone #{repo} dotfiles]

      dotfiles_in(checkout_dir) do |file| 
        ln file,'.'
      end
    end
_cd 13; rake test_

!SLIDE smaller
# Fast-Forward
_cd 15; rake test_
    @@@Ruby
    def main(repo,checkout_dir)
      checkout_dir = ENV['HOME'] if checkout_dir.nil?
      begin
        mkdir_p checkout_dir
      rescue
        raise "Problem creating directory #{checkout_dir}"
      end
      begin
        chdir checkout_dir
      rescue
        raise "Problem changing to directory #{checkout_dir}"
      end

      unless system("git clone #{repo} dotfiles")
        raise "Problem checking out #{repo} into #{checkout_dir}/dotfiles"
      end

      dotfiles_in(checkout_dir) do |file| 
        begin
          ln file,'.'
        rescue
          raise "Problem symlinking #{file} into #{checkout_dir}"
        end
      end
    end

!SLIDE
# Refactor

    @@@Ruby
    def method_missing(sym,*args)
      if FileUtils.respond_to? sym
        begin
          FileUtils.send(sym,*args)
          true
        rescue
          false
        end
      else
        super(sym,*args)
      end
    end


!SLIDE smaller
# Refactor

    @@@Ruby
    #include FileUtils
    def main(repo,checkout_dir)
      checkout_dir = ENV['HOME'] if checkout_dir.nil?

      mkdir_p checkout_dir or 
        raise "Problem creating directory #{checkout_dir}"
      chdir checkout_dir or 
        raise "Problem changing to directory #{checkout_dir}"

      system("git clone #{repo} dotfiles") or
        raise "Problem checking out #{repo} into #{checkout_dir}/dotfiles"

      dotfiles_in(checkout_dir) do |file| 
        ln file,'.' or 
          raise "Problem symlinking #{file} into #{checkout_dir}"
      end
    end

_ cd 16; rake features_

!SLIDE bullets incremental
# We have a new problem
* Nice error messages
* Poor user still gets a backtrace
* Refactor

_5:00_

!SLIDE commandline incremental
# What we want

    $ fullstop /some/unknown/repo
    error: Problem checking out /some/unknown/repo
    $ echo $?
    1 # => or some other nonzero value

!SLIDE bullets incremental
# Getting there
* Only coverage of `bin/fullstop` is cuke tests

!SLIDE smaller
# New feature

    @@@Cucumber
    Scenario: Handle failures gracefully
      Given an empty directory "/tmp/dotfiles"
      When I run `fullstop /tmp/dotfiles`
      Then the exit status should not be 0
      And the output should contain \
          "Problem checking out /tmp/dotfiles"
      But the output should not contain a backtrace

!SLIDE smaller
# Check for backtrace
## (cheesily)

    @@@Ruby
    Then /^the output should not contain a backtrace$/ do
      Then %(the output should not contain "`<main>'")
    end

!SLIDE
# Watch it fail
_cd 17; rake features_

!SLIDE commandline smaller
# Watch it fail

    $ rake features
    Scenario: Handle failures gracefully
        Given an empty directory "/tmp/dotfiles"
        When I run `fullstop /tmp/dotfiles`
        Then the exit status should not be 0
        And the output should not contain a backtrace
          expected "fatal: repository '/tmp/dotfiles' does not exist\n/Users/davec/Projects/tdd_talk/fullstop/17/lib/fullstop/cli.rb:14:in `main': Problem checking out /tmp/dotfiles into /tmp/fakehome/dotfiles (RuntimeError)\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/17/bin/fullstop:22:in `<main>'\n" not to include "`<main>'"
          Diff:
          @@ -1,2 +1,4 @@
          -`<main>'
          +fatal: repository '/tmp/dotfiles' does not exist
          +/Users/davec/Projects/tdd_talk/fullstop/17/lib/fullstop/cli.rb:14:in `main': Problem checking out /tmp/dotfiles into /tmp/fakehome/dotfiles (RuntimeError)
          +	from /Users/davec/Projects/tdd_talk/fullstop/17/bin/fullstop:22:in `<main>'
           (RSpec::Expectations::ExpectationNotMetError)
          features/fullstop.feature:32:in `And the output should not contain a backtrace'
        But the output should contain "Problem checking out /tmp/dotfiles"

    Failing Scenarios:
    cucumber features/fullstop.feature:28

    4 scenarios (1 failed, 3 passed)
    20 steps (1 failed, 1 skipped, 18 passed)
    0m0.516s
    rake aborted!
    Cucumber failed


!SLIDE
# Fix

    @@@Ruby
    
      main(repo,checkout_dir)
    
    
    
    #

!SLIDE
# Fix

    @@@Ruby
    begin
      main(repo,checkout_dir)
    rescue Exception => ex
      STDERR.puts "error: #{ex.message}"
      exit 1
    end

!SLIDE
# Still green?

!SLIDE commandline smaller
# Still green
    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/18)
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

      Scenario: The UI should be good
        Given the name of the app is "fullstop"
        When I run `fullstop --help`
        Then it should have a banner
        And the banner should indicate that there are no options
        And the banner should document the arguments as:
          | dotfiles_repo | required |
          | checkout_dir  | optional |
        And there should be a one-line summary of what the app does

      Scenario: Handle failures gracefully
        Given an empty directory "/tmp/dotfiles"
        When I run `fullstop /tmp/dotfiles`
        Then the exit status should not be 0
        And the output should not contain a backtrace
        But the output should contain "Problem checking out /tmp/dotfiles"

    4 scenarios (4 passed)
    20 steps (20 passed)
    0m0.520s

