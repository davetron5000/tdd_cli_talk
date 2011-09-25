Feature: Install my dotfiles
  In order to set up a new user account quickly
  As a developer with his dotfiles in git
  I should be able to maintain them easily

  Scenario: Symlink my dotfiles
    Given I have my dotfiles in a git at "/tmp/testdotfiles"
    When I successfully run `fullstop /tmp/testdotfiles`
    Then my dotfiles should be checked out as "dotfiles" in my home directory
    And my dotfiles should be symlinked in my home directory

  Scenario: The UI is not sucky
    When I get help for "fullstop"
    Then the exit status should be 0
    And the banner should be present
    And the banner should document that this app takes no options
    And the banner should document that this app's arguments are:
      |repo|which is required|
    And there should be a one line summary of what the app does
