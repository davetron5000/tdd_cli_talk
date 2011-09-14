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
        |dotfiles_repo|which is required|
        |checkout_dir |which is optional|
    And there should be a one-line summary of what the app does

