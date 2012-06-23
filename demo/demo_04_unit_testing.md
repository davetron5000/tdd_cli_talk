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

        def      main(repo,home_dir)
          chdir home_dir
          %x[git clone #{repo} #{DOTFILES}]

          dotfiles_in(File.join(home_dir,DOTFILES)) do |file|
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

        def self.main(repo,home_dir)
          chdir home_dir
          %x["git clone #{repo} #{DOTFILES}"]

          dotfiles_in(File.join(home_dir,DOTFILES)) do |file|
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

        def self.main(repo,home_dir)
          chdir home_dir
          system("git clone #{repo} #{DOTFILES}")

          dotfiles_in(File.join(home_dir,DOTFILES)) do |file|
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
    require 'fullstop/cli'
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

  Scenario: The UI is not sucky
    <span class='ansi-32'>When I get help for "<span class='ansi-32'><span class='ansi-1'>fullstop<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>Then the exit status should be <span class='ansi-32'><span class='ansi-1'>0<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'><span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And the banner should be present<span class='ansi-0'></span></span>
    <span class='ansi-32'>And the banner should document that this app takes no options<span class='ansi-0'></span></span>
    <span class='ansi-32'>And the banner should document that this app's arguments are:<span class='ansi-0'></span></span>
      | <span class='ansi-32'>repo<span class='ansi-0'><span class='ansi-0'> |<span class='ansi-0'> <span class='ansi-32'>which is required<span class='ansi-0'><span class='ansi-0'> |<span class='ansi-0'></span></span></span></span></span></span></span></span>
    <span class='ansi-32'>And there should be a one line summary of what the app does<span class='ansi-0'></span></span>

  Scenario: File already exists and cannot be symlinked
    <span class='ansi-32'>Given I have my dotfiles in git at "<span class='ansi-32'><span class='ansi-1'>/tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And the file "<span class='ansi-32'><span class='ansi-1'>.bashrc<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>" exists in my home directory<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>When I run `<span class='ansi-32'><span class='ansi-1'>fullstop /tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>`<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>Then the exit status should not be <span class='ansi-32'><span class='ansi-1'>0<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'><span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And the stderr should contain "<span class='ansi-32'><span class='ansi-1'>File exists<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And the output should not contain a backtrace<span class='ansi-0'></span></span>

3 scenarios (<span class='ansi-32'>3 passed<span class='ansi-0'>)</span></span>
16 steps (<span class='ansi-32'>16 passed<span class='ansi-0'>)</span></span>
0m0.483s
</pre>


!SLIDE bullets incremental
# Approach
* Any problem...
* ...raise (a useful message)
* `bin/fullstop` already handles the UI

!SLIDE bullets incremental
# New test
* `FileUtils` methods already throw exceptions
* `system` returns `true` or `false`

!SLIDE small
# Test
## Givens

    @@@Ruby
    include Fullstop
    def test_git_failure_causes_exception
      CLI.stubs(:chdir)
      CLI.stubs(:system).returns(false)
      CLI.stubs(:ln_s).raises(
              "Should not have been called")
      
     
    
   
  
    end

_11_

!SLIDE small
# Test
## When

    @@@Ruby
    include Fullstop
    def test_git_failure_causes_exception
      CLI.stubs(:chdir)
      CLI.stubs(:system).returns(false)
      CLI.stubs(:ln_s).raises(
              "Should not have been called")
      
        CLI.main('foo','foo')
      
      
      
    end

_11_
!SLIDE small
# Test
## Then

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
    def self.main(repo,home_dir)
      chdir home_dir
      system("git clone #{repo} #{DOTFILES}")
      
      

      dotfiles_in(File.join(home_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

_12_

!SLIDE smaller
# Fix

    @@@Ruby
    def self.main(repo,home_dir)
      chdir home_dir
      unless system("git clone #{repo} #{DOTFILES}")
        raise "'git clone #{repo} #{DOTFILES}' failed"
      end

      dotfiles_in(File.join(home_dir,DOTFILES)) do |file|
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
    def self.main(repo,home_dir)
      chdir home_dir
      unless system("git clone #{repo} #{DOTFILES}")
        raise "'git clone #{repo} #{DOTFILES}' failed"
      end

      dotfiles_in(File.join(home_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

    

    #

!SLIDE small
# Refactor

    @@@Ruby
    unless  # ...
      raise  # ...
    end

!SLIDE small
# Refactor

    @@@Ruby
    "git clone #{repo} #{DOTFILES}"

!SLIDE smaller
# Refactor

    @@@Ruby
    def self.main(repo,home_dir)
      chdir home_dir
      unless system("git clone #{repo} #{DOTFILES}")
        raise "'git clone #{repo} #{DOTFILES}' failed"
      end

      dotfiles_in(File.join(home_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

    

    #

_13_

!SLIDE smaller
# Refactor

    @@@Ruby
    def self.main(repo,home_dir)
      chdir home_dir
      sh! "git clone #{repo} #{DOTFILES}"

      dotfiles_in(File.join(home_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

    def self.sh!(command)
      unless system(command)
        raise "'#{command}' failed"
      end
    end

_13_

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

  Scenario: The UI is not sucky
    <span class='ansi-32'>When I get help for "<span class='ansi-32'><span class='ansi-1'>fullstop<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>Then the exit status should be <span class='ansi-32'><span class='ansi-1'>0<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'><span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And the banner should be present<span class='ansi-0'></span></span>
    <span class='ansi-32'>And the banner should document that this app takes no options<span class='ansi-0'></span></span>
    <span class='ansi-32'>And the banner should document that this app's arguments are:<span class='ansi-0'></span></span>
rm -rf /tmp/fakehome
mkdir -p /tmp/fakehome
      | <span class='ansi-32'>repo<span class='ansi-0'><span class='ansi-0'> |<span class='ansi-0'> <span class='ansi-32'>which is required<span class='ansi-0'><span class='ansi-0'> |<span class='ansi-0'></span></span></span></span></span></span></span></span>
    <span class='ansi-32'>And there should be a one line summary of what the app does<span class='ansi-0'></span></span>

  Scenario: File already exists and cannot be symlinked
    <span class='ansi-32'>Given I have my dotfiles in git at "<span class='ansi-32'><span class='ansi-1'>/tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And the file "<span class='ansi-32'><span class='ansi-1'>.bashrc<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>" exists in my home directory<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>When I run `<span class='ansi-32'><span class='ansi-1'>fullstop /tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>`<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>Then the exit status should not be <span class='ansi-32'><span class='ansi-1'>0<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'><span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And the stderr should contain "<span class='ansi-32'><span class='ansi-1'>File exists<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And the output should not contain a backtrace<span class='ansi-0'></span></span>

3 scenarios (<span class='ansi-32'>3 passed<span class='ansi-0'>)</span></span>
16 steps (<span class='ansi-32'>16 passed<span class='ansi-0'>)</span></span>
0m0.482s
</pre>
