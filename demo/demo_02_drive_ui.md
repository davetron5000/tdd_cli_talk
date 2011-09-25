!SLIDE subsection 
# The UI sucks

!SLIDE smaller

    @@@Cucumber
    Scenario: The UI is not sucky
      When I get help for "fullstop"
      Then the exit status should be 0
      And the banner should be present
      And the banner should document that 
        this app takes no options
      And the banner should document that 
        this app's arguments are:
          |repo|which is required|
      And there should be a one line summary of what the app does

!SLIDE 
# All steps provided by Aruba or Methadone

!SLIDE  smaller
# [Sample implementation](https://github.com/davetron5000/methadone/blob/master/lib/methadone/cucumber.rb)

    @@@Ruby
    When /^I get help for "([^"]*)"$/ do |app_name|
      @app_name = app_name
      When %(I run `#{app_name} --help`)
    end

    Then /^the banner should be present$/ do
      Then %(the output should match /Usage: #{@app_name}/)
    end

!SLIDE 
# Let's try it

_06_

!SLIDE commandline smaller
    $ rake features
      Scenario: The UI is not sucky
        When I get help for "fullstop"
        Then the exit status should be 0
        And the banner should be present
        And the banner should document that this app takes no options
          expected "Usage: fullstop [options]\n" not to include "[options]"
          Diff:
          @@ -1,2 +1,2 @@
          -[options]
          +Usage: fullstop [options]
           (RSpec::Expectations::ExpectationNotMetError)
          features/fullstop.feature:16:in `And the banner should document that this app takes no options'
        And the banner should document that this app's arguments are:
          | repo | which is required |
        And there should be a one line summary of what the app does

    Failing Scenarios:
    cucumber features/fullstop.feature:12

    2 scenarios (1 failed, 1 passed)
    10 steps (1 failed, 2 skipped, 7 passed)

!SLIDE smaller
# Easiest fix ever

    @@@Ruby
    option_parser = OptionParser.new do |opts|
      
      
      
    end

    option_parser.parse!

    main(ARGV[0],ENV['HOME'])

!SLIDE smaller
# Easiest fix ever

    @@@Ruby
    option_parser = OptionParser.new do |opts|
      executable = File.basename(__FILE__)
      opts.banner = "Usage: #{executable} repo\n\n" +
        "Manage your dotfiles from a git repo"
    end

    option_parser.parse!

    main(ARGV[0],ENV['HOME'])


!SLIDE bullets incremental
# Refactor?
* Nah
