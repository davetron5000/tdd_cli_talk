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

!SLIDE bullets incremental
# Design will need to change
* How to test those system calls?
* What do we do when one fails?

!SLIDE 
# First, let's get a testable unit

!SLIDE
# Refactor

!SLIDE smaller
    @@@Ruby
    #!/usr/bin/env ruby -w

    $: << File.expand_path(File.dirname(File.realpath(__FILE__)) + 
          '/../lib') 

    require 'optparse'
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
* Abstract `FileUtils` calls?
* Mock `FileUtils`?
* Mock filesystem?

!SLIDE
# Let's mock the filesystem

