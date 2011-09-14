!SLIDE subsection 
# The UI sucks

!SLIDE smaller

    @@@Cucumber
    Scenario: The UI should be good
      Given the name of the app is "fullstop"
      When I run `fullstop --help`
      Then it should have a banner
      And the banner should indicate that there are no options
      And the banner should document the arguments as:
          |dotfiles_repo|required|
          |checkout_dir |optional|
      And there should be a one-line summary of what the app does
        

!SLIDE bullets incremental
# Approach
* Aruba's `the output should match`

!SLIDE  smaller
# Implement the steps

    @@@Ruby
    Given /^the name of the app is "([^"]*)"$/ do |app_name|
      @app_name = app_name
    end

    Then /^it should have a banner$/ do
      Then %(the output should match /^Usage: #{@app_name}.*$/)
    end

    Then /^the banner should indicate that there are no options$/ do
      Then %(the output should not contain "[options]")
    end

!SLIDE smaller
# Checking for arguments

    @@@Ruby
    Then /^the banner should document the arguments as:$/ do |table|
      argument_string = table.raw.map { |row|
        option = row[0]
        option = "[#{row[0]}]" unless row[1] == 'required'
        option
      }.join(' ')
      Then %(the output should contain "#{argument_string}")
    end

!SLIDE smaller
# Checking for summary

    @@@Ruby
    Then /^there should be a one\-line summary of what the app does$/ do
      output_lines = all_output.split(/\n/)
      output_lines.should have_at_least(3).items
      # [0] is our usage, which we've checked for
      output_lines[1].should match(/^\s*$/)
      output_lines[2].should match(/^\w+\s+\w+/)
    end
!SLIDE
# Now, we have a failing test
   
_cd 08; rake features_

!SLIDE commandline smaller
# Now, we have a failing test
    $ rake features
    (in /Users/davec/Projects/tdd_talk/fullstop/08)
    Feature: Install my dotfiles
      As an organized developer who has his dotfiles on github
      I want to be able to set up a new user account easily

      Scenario: The UI should be good
        Given the name of the app is "fullstop"
        When I run `fullstop --help`
        Then it should have a banner
        And the banner should indicate that there are no options
          expected "Usage: fullstop [options]\n" not to include "[options]"
          Diff:
          @@ -1,2 +1,2 @@
          -[options]
          +Usage: fullstop [options]
           (RSpec::Expectations::ExpectationNotMetError)
          features/fullstop.feature:22:in `And the banner should indicate that there are no options'
        And the banner should document the arguments as:
          | dotfiles_repo | required |
          | checkout_dir  | optional |
        And there should be a one-line summary of what the app does

    Failing Scenarios:
    cucumber features/fullstop.feature:18

!SLIDE small

    @@@Ruby
    opts.banner = "Usage: #{executable_name} [options]"

!SLIDE small

    @@@Ruby
    opts.banner = "Usage: #{executable_name}"

!SLIDE small

    @@@Ruby
    opts.banner = "Usage: #{executable_name}\n\n" + 
      "Manages your dotfiles from a git repo"

!SLIDE
# Fixed?

_cd 10 ; rake features_

!SLIDE commandline

    $ rake features
    Scenario: The UI should be good
    Given the name of the app is "fullstop"
    When I run `fullstop --help`
    Then it should have a banner
    And the banner should indicate that there are no options
    And the banner should document the arguments as:
      | dotfiles_repo | required |
      | checkout_dir  | optional |
    And there should be a one-line summary of what the app does

!SLIDE bullets incremental
# Nice!
* Happy path sure is happy

