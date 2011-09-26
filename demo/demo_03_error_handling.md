!SLIDE subsection
# Unhappy Path

!SLIDE smaller

    @@@Ruby
    def main(repo,link_dir)
      chdir link_dir
      %x[git clone #{repo} #{DOTFILES}]

      dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

!SLIDE smaller

    @@@Ruby
    def main(repo,link_dir)
      chdir link_dir                    # <= !
      %x[git clone #{repo} #{DOTFILES}] # <= !

      dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
        ln_s file,'.'                   # <= !
      end
    end

!SLIDE commandline incremental smaller
# What happens?
    $ HOME=/tmp/fakehome bin/fullstop /tmp/testdotfiles
    $ rm -rf /tmp/fakehome/dotfiles/
    $ HOME=/tmp/fakehome bin/fullstop /tmp/testdotfiles
    fileutils.rb:347:in `symlink': File exists - (/tmp/fakehome/dotfiles/.bashrc, ./.bashrc) (Errno::EEXIST)
      from fileutils.rb:347:in `block in ln_s'
      from fileutils.rb:1437:in `fu_each_src_dest0'
      from fileutils.rb:345:in `ln_s'
      from bin/fullstop:15:in `block in main'
      from bin/fullstop:23:in `block in dotfiles_in'
      from bin/fullstop:20:in `each'
      from bin/fullstop:20:in `dotfiles_in'
      from bin/fullstop:14:in `main'
      from bin/fullstop:35:in `<main>'
       
!SLIDE bullets incremental
# What's wrong?
* Horrible backtrace
* Lame error message

!SLIDE smaller
    @@@Cucumber
    Scenario: File already exists and cannot be symlinked
      Given I have my dotfiles in git at "/tmp/testdotfiles"
      And the file ".bashrc" exists in my home directory
      When I run `fullstop /tmp/testdotfiles`
      Then the exit status should not be 0
      And the stderr should contain "File exists"
      And the stderr should contain ".bashrc"
      And the output should not contain a backtrace

!SLIDE smaller
    @@@Ruby
    Given 
    /^the file "([^"]*)" exists in my home directory$/ do |file|
      touch File.join(ENV['HOME'],file)
    end

    Then /^the output should not contain a backtrace$/ do
      Then %(the output should not contain "<main>")
    end

_08_

!SLIDE commandline smaller

    $ rake features
      Scenario: File already exists and cannot be symlinked
        Given I have my dotfiles in git at "/tmp/testdotfiles"
    touch /tmp/fakehome/.bashrc
        And the file ".bashrc" exists in my home directory
        When I run `fullstop /tmp/testdotfiles`
        Then the exit status should not be 0
        And the stderr should contain "in `symlink': File exists"
        And the stderr should contain "(Errno::EEXIST)"
        And the output should not contain a backtrace
          expected "/Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:347:in `symlink': File exists - (/tmp/fakehome/dotfiles/.bashrc, ./.bashrc) (Errno::EEXIST)\n\tfrom /Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:347:in `block in ln_s'\n\tfrom /Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:1437:in `fu_each_src_dest0'\n\tfrom /Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:345:in `ln_s'\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:15:in `block in main'\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:23:in `block in dotfiles_in'\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:20:in `each'\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:20:in `dotfiles_in'\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:14:in `main'\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:35:in `<main>'\n" not to include "<main>"
          Diff:
          @@ -1,2 +1,11 @@
          -<main>
          +/Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:347:in `symlink': File exists - (/tmp/fakehome/dotfiles/.bashrc, ./.bashrc) (Errno::EEXIST)
          +	from /Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:347:in `block in ln_s'
          +	from /Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:1437:in `fu_each_src_dest0'
          +	from /Users/davec/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/fileutils.rb:345:in `ln_s'
          +	from /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:15:in `block in main'
          +	from /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:23:in `block in dotfiles_in'
          +	from /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:20:in `each'
          +	from /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:20:in `dotfiles_in'
          +	from /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:14:in `main'
          +	from /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:35:in `<main>'
           (RSpec::Expectations::ExpectationNotMetError)
          features/fullstop.feature:28:in `And the output should not contain a backtrace'

    Failing Scenarios:
    cucumber features/fullstop.feature:21

    3 scenarios (1 failed, 2 passed)
    17 steps (1 failed, 16 passed)
    0m0.488s
    rake aborted!
    Cucumber failed


!SLIDE
    @@@Ruby
    
      main(ARGV[0],ENV['HOME'])
    
    
    
    #

!SLIDE
    @@@Ruby
    begin
      main(ARGV[0],ENV['HOME'])
    rescue Exception => ex
      STDERR.puts ex.message
      exit 1
    end

_09_

!SLIDE
# 
