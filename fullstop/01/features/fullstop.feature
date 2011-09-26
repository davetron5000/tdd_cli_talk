Feature: Install my dotfiles
  In order to set up a new user account quickly
  As a developer with his dotfiles in git
  I should be able to maintain them easily

  Scenario: Symlink my dotfiles
    Given I have my dotfiles in git at "/tmp/testdotfiles"
    When I successfully run `fullstop /tmp/testdotfiles`
    Then my dotfiles should be checked out as "dotfiles" in my home directory
    And my dotfiles should be symlinked in my home directory

