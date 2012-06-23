!SLIDE subsection 
# The UI sucks

!SLIDE commandline incremental

    $ bin/fullstop --help
    Usage: fullstop [options]

!SLIDE commandline

    $ bin/fullstop --help
    Usage: fullstop [options]
                    ^^^^^^^^^

!SLIDE commandline

    $ bin/fullstop --help
    Usage: fullstop [options]
                               ^^^^^^^^^


!SLIDE smaller1

    @@@Cucumber
    Scenario: The UI is not sucky
      When I get help for "fullstop"
      Then the exit status should be 0
      And the banner should be present
      And the banner should document that this app takes no options
      And the banner should document that this app's arguments are:
          |repo|which is required|
      And there should be a one line summary of what the app does

!SLIDE 
# All steps provided by Aruba or Methadone

!SLIDE  smaller
# [Sample implementation](https://github.com/davetron5000/methadone/blob/master/lib/methadone/cucumber.rb)

    @@@Ruby
    When /^I get help for "([^"]*)"$/ do |app_name|
      @app_name = app_name
      step %(I run `#{app_name} --help`)
    end

    Then /^the banner should be present$/ do
      step %(the output should match /Usage: #{@app_name}/)
    end

!SLIDE 
# Let's try it

_06_

!SLIDE commandline smaller
<pre style="font-size: 18px">
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
rake aborted!
Cucumber failed

Tasks: TOP => features
(See full trace by running task with --trace)
    <span class='ansi-32'>When I get help for "<span class='ansi-32'><span class='ansi-1'>fullstop<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'>"<span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>Then the exit status should be <span class='ansi-32'><span class='ansi-1'>0<span class='ansi-0'><span class='ansi-0'><span class='ansi-32'><span class='ansi-0'></span></span></span></span></span></span></span>
    <span class='ansi-32'>And the banner should be present<span class='ansi-0'></span></span>
    <span class='ansi-31'>And the banner should document that this app takes no options<span class='ansi-0'></span></span>
<span class='ansi-31'>      expected "Usage: fullstop [options]\n" not to include "[options]"<span class='ansi-0'></span></span>
<span class='ansi-31'>      Diff:<span class='ansi-0'></span></span>
<span class='ansi-31'>      @@ -1,2 +1,2 @@<span class='ansi-0'></span></span>
<span class='ansi-31'>      -[options]<span class='ansi-0'></span></span>
<span class='ansi-31'>      +Usage: fullstop [options]<span class='ansi-0'></span></span>
<span class='ansi-31'>       (RSpec::Expectations::ExpectationNotMetError)<span class='ansi-0'></span></span>
<span class='ansi-31'>      features/fullstop.feature:16:in `And the banner should document that this app takes no options'<span class='ansi-0'></span></span>
    <span class='ansi-36'>And the banner should document that this app's arguments are:<span class='ansi-0'></span></span>
      | <span class='ansi-36'>repo<span class='ansi-0'><span class='ansi-0'> |<span class='ansi-0'> <span class='ansi-36'>which is required<span class='ansi-0'><span class='ansi-0'> |<span class='ansi-0'></span></span></span></span></span></span></span></span>
    <span class='ansi-36'>And there should be a one line summary of what the app does<span class='ansi-0'></span></span>

<span class='ansi-31'>Failing Scenarios:<span class='ansi-0'></span></span>
<span class='ansi-31'>cucumber features/fullstop.feature:12<span class='ansi-0'></span></span>

2 scenarios (<span class='ansi-31'>1 failed<span class='ansi-0'>, <span class='ansi-32'>1 passed<span class='ansi-0'>)</span></span></span></span>
10 steps (<span class='ansi-31'>1 failed<span class='ansi-0'>, <span class='ansi-36'>2 skipped<span class='ansi-0'>, <span class='ansi-32'>7 passed<span class='ansi-0'>)</span></span></span></span></span></span>
0m0.322s
</pre>

!SLIDE small
# Easiest fix ever

    @@@Ruby
    option_parser = OptionParser.new do |opts|
      
      
      
    end

    option_parser.parse!

    main(ARGV[0],ENV['HOME'])

_07_

!SLIDE small
# Easiest fix ever

    @@@Ruby
    option_parser = OptionParser.new do |opts|
      executable = File.basename(__FILE__)
      opts.banner = "Usage: #{executable} repo\n\n" +
        "Manage your dotfiles from a git repo"
    end

    option_parser.parse!

    main(ARGV[0],ENV['HOME'])

_07_

!SLIDE bullets incremental
# Refactor?
* Nah
