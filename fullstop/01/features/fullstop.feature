Feature: Install my dotfiles
  As an organized developer who has his dotfiles on github
  I want to be able to set up a new user account easily

  Scenario: Symlink my dotfiles to an arbitrary directory
    Given an empty directory "/tmp/dotfiles"
    And I have my dotfiles in a git repo at "/Users/davec/Projects/testdotfiles"
    When I successfully run `fullstop /Users/davec/Projects/testdotfiles /tmp/dotfiles`
    Then my dotfiles should be checked out in "/tmp/dotfiles/dotfiles"
    And my dotfiles should be symlinked in "/tmp/dotfiles"
