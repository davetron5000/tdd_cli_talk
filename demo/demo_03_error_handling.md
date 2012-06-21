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
# Horrible backtrace

!SLIDE smaller
    @@@Cucumber
    Scenario: File already exists and cannot be symlinked
      Given I have my dotfiles in git at "/tmp/testdotfiles"
      And the file ".bashrc" exists in my home directory
      When I run `fullstop /tmp/testdotfiles`
      Then the exit status should not be 0
      And the stderr should match /File exists/
      And the output should not contain a backtrace

!SLIDE smaller2
    @@@Ruby
    Given /^the file "([^"]*)" exists in my home directory$/ do |file|
      touch File.join(ENV['HOME'],file)
    end

    Then /^the output should not contain a backtrace$/ do
      Then %(the output should not contain "<main>")
    end

_08_

!SLIDE 
<pre style="font-size: 18px">
Feature: Install my dotfiles
  In order to set up a new user account quickly
  As a developer with his dotfiles in git
  I should be able to maintain them easily

  Scenario: File already exists and cannot be symlinked
    <span class='ansi-32'>Given I have my dotfiles in git at "<span class='ansi-32'><span class='ansi-1'>/tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And the file "<span class='ansi-32'><span class='ansi-1'>.bashrc<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>" exists in my home directory<span class='ansi-0'></span></span></span></span></span></span></span>
rake aborted!
Cucumber failed

Tasks: TOP => features
(See full trace by running task with --trace)
    <span class='ansi-32'>When I run `<span class='ansi-32'><span class='ansi-1'>fullstop /tmp/testdotfiles<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>`<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>Then the exit status should not be <span class='ansi-32'><span class='ansi-1'>0<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'><span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And the stderr should contain "<span class='ansi-32'><span class='ansi-1'>File exists<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-31'>And the output should not contain a backtrace<span class='ansi-0'></span></span>
<span class='ansi-31'>      expected "/Users/davec/.rvm/rubies/ruby-1.9.2-p318/lib/ruby/1.9.1/fileutils.rb:347:in `symlink': File exists - (/tmp/fakehome/dotfiles/.bashrc, ./.bashrc) (Errno::EEXIST)\n\tfrom /Users/davec/.rvm/rubies/ruby-1.9.2-p318/lib/ruby/1.9.1/fileutils.rb:347:in `block in ln_s'\n\tfrom /Users/davec/.rvm/rubies/ruby-1.9.2-p318/lib/ruby/1.9.1/fileutils.rb:1437:in `fu_each_src_dest0'\n\tfrom /Users/davec/.rvm/rubies/ruby-1.9.2-p318/lib/ruby/1.9.1/fileutils.rb:345:in `ln_s'\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:15:in `block in main'\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:23:in `block in dotfiles_in'\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:20:in `each'\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:20:in `dotfiles_in'\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:14:in `main'\n\tfrom /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:35:in `<main>'\n" not to include "<main>"<span class='ansi-0'></span></span>
<span class='ansi-31'>      Diff:<span class='ansi-0'></span></span>
<span class='ansi-31'>      @@ -1,2 +1,11 @@<span class='ansi-0'></span></span>
<span class='ansi-31'>      -<main><span class='ansi-0'></span></span>
<span class='ansi-31'>      +/Users/davec/.rvm/rubies/ruby-1.9.2-p318/lib/ruby/1.9.1/fileutils.rb:347:in `symlink': File exists - (/tmp/fakehome/dotfiles/.bashrc, ./.bashrc) (Errno::EEXIST)<span class='ansi-0'></span></span>
<span class='ansi-31'>      +	from /Users/davec/.rvm/rubies/ruby-1.9.2-p318/lib/ruby/1.9.1/fileutils.rb:347:in `block in ln_s'<span class='ansi-0'></span></span>
<span class='ansi-31'>      +	from /Users/davec/.rvm/rubies/ruby-1.9.2-p318/lib/ruby/1.9.1/fileutils.rb:1437:in `fu_each_src_dest0'<span class='ansi-0'></span></span>
<span class='ansi-31'>      +	from /Users/davec/.rvm/rubies/ruby-1.9.2-p318/lib/ruby/1.9.1/fileutils.rb:345:in `ln_s'<span class='ansi-0'></span></span>
<span class='ansi-31'>      +	from /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:15:in `block in main'<span class='ansi-0'></span></span>
<span class='ansi-31'>      +	from /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:23:in `block in dotfiles_in'<span class='ansi-0'></span></span>
<span class='ansi-31'>      +	from /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:20:in `each'<span class='ansi-0'></span></span>
<span class='ansi-31'>      +	from /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:20:in `dotfiles_in'<span class='ansi-0'></span></span>
<span class='ansi-31'>      +	from /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:14:in `main'<span class='ansi-0'></span></span>
<span class='ansi-31'>      +	from /Users/davec/Projects/tdd_talk/fullstop/08/bin/fullstop:35:in `<main>'<span class='ansi-0'></span></span>
<span class='ansi-31'>       (RSpec::Expectations::ExpectationNotMetError)<span class='ansi-0'></span></span>
<span class='ansi-31'>      features/fullstop.feature:27:in `And the output should not contain a backtrace'<span class='ansi-0'></span></span>

<span class='ansi-31'>Failing Scenarios:<span class='ansi-0'></span></span>
<span class='ansi-31'>cucumber features/fullstop.feature:21<span class='ansi-0'></span></span>

3 scenarios (<span class='ansi-31'>1 failed<span class='ansi-0'>, <span class='ansi-32'>2 passed<span class='ansi-0'>)</span></span></span></span>
16 steps (<span class='ansi-31'>1 failed<span class='ansi-0'>, <span class='ansi-32'>15 passed<span class='ansi-0'>)</span></span></span></span>
0m0.484s
</pre>

!SLIDE
    @@@Ruby
 
      main(ARGV[0],ENV['HOME'])
  
   
    
    #

_09_
!SLIDE
    @@@Ruby
    begin
      main(ARGV[0],ENV['HOME'])
    rescue Exception => ex
      STDERR.puts ex.message
      exit 1
    end

_09_

!SLIDE bullets incremental
# That's just one case 
* Edge cases hard to simulate with an acceptance test
* Lots of set up
* Potentially Fragile

!SLIDE bullets incremental
# Time for Unit tests
* Unit tests run fast
* Testable units are **good**
