Feature: Edit keyboard shortcuts
  In order to improve productivity
  I want to have a tool for managing shell keyboard shortcuts
  So I don't have to do it myself

  Background:
    Given a file named ".aka.yml" should not exist
    And I set the AKA environment variable to the ".aka.yml" file in the working directory
    And I set the environment variables to:
    | variable | value |
    | NO_MAN   | 1     |

  Scenario: Edit
    Given I run `aka add ls "ls -F --color=auto"`
    And a file named "input.txt" with:
    """
    Shortcut: lsf
    Description:
    1
    2
    3
    Function (y/n): y
    Tags: zsh, bash
    Command:
    ls -F
    """
    When I run `aka edit ls -i input.txt`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Saved shortcut.

    """
    And the file ".aka.yml" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    Saved shortcut.
    #zsh
    ====
    lsf                           1; 2; 3

    #bash
    =====
    lsf                           1; 2; 3
    """

  Scenario: Edit to remove tag
    Given I run `aka add ls "ls -F --color=auto" --tag zsh`
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    #zsh
    ====
    ls                            ls -F --color=auto
    """
    And a file named "input.txt" with:
    """
    Shortcut: lsf
    Description:
    1
    2
    3
    Function (y/n): y
    Tags:
    Command:
    ls -F
    """
    When I run `aka edit ls -i input.txt`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    #zsh
    ====
    ls                            ls -F --color=auto

    Saved shortcut.

    """
    And the file ".aka.yml" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    #zsh
    ====
    ls                            ls -F --color=auto

    Saved shortcut.
    #default
    ========
    lsf                           1; 2; 3
    """

  Scenario: Edit that clears command
    Given I run `aka add ls "ls -F --color=auto" --tag zsh`
    And a file named "input.txt" with:
    """
    Shortcut: lsf
    Description:
    1
    2
    3
    Function (y/n): y
    Tags:
    Command:
    """
    When I run `aka edit ls -i input.txt`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Saved shortcut.

    """
    And the file ".aka.yml" should exist
    When I run `aka list`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Saved shortcut.
    #default
    ========
    lsf                           1; 2; 3
    """

  # When in interactive mode, edit the shorcut so it looks like this:
  # Shortcut: lsf
  # Description:
  # 1
  # 2
  # 3
  # Function (y/n): y
  # Tags: zsh, bash
  # Command:
  # ls -F
  @interactive
  Scenario: Edit interactively
    Given I run `aka add ls "ls -F --color=auto"`
    When I run `aka edit ls` interactively
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Saved shortcut.

    """
    And the file ".aka.yml" should exist
    When I run `aka list`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Saved shortcut.
    #zsh
    ====
    lsf                           1; 2; 3

    #bash
    =====
    lsf                           1; 2; 3
    """

  Scenario: Edit: Missing shortcut
    When I run `aka edit ls`
    Then the exit status should not be 0
    And the output should contain exactly:
    """
    Shortcut not found.

    """
