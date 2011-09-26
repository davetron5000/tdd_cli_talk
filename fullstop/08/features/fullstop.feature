Feature: Install my dotfiles
  In order to set up a new user account quickly
  As a developer with his dotfiles in git
  I should be able to maintain them easily

  Scenario: Symlink my dotfiles
    Given I have my dotfiles in git at "/tmp/testdotfiles"
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

  Scenario: File already exists and cannot be symlinked
    Given I have my dotfiles in git at "/tmp/testdotfiles"
    And the file ".bashrc" exists in my home directory
    When I run `fullstop /tmp/testdotfiles`
    Then the exit status should not be 0
    And the stderr should contain "File exists"
    And the stderr should contain ".bashrc"
    And the output should not contain a backtrace
