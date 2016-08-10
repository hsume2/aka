Feature: Add keyboard shortcuts
  In order to improve productivity
  I want to have a tool for managing shell keyboard shortcuts
  So I don't have to do it myself

  Background:
    Given a file named ".aka.db" should not exist
    And I set the AKA environment variable to the ".aka.db" file in the working directory
    And I set the environment variables to:
    | variable | value |
    | NO_MAN   | 1     |


  Scenario: Create new shortcut
    When I run `aka add ls "ls -F --color=auto"`
    Then the exit status should be 0
    And the output should contain:
    """
    Created shortcut.
    """
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    #default
    ========
    ls                            ls -F --color=auto
    """

  Scenario: Create new shortcut with tag
    When I run `aka add ls "ls -F --color=auto" -t os:darwin`
    Then the exit status should be 0
    And the output should contain:
    """
    Created shortcut.
    """
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    #os:darwin
    ==========
    ls                            ls -F --color=auto
    """

  Scenario: Create new shortcut with multiple tags
    When I run `aka add ls "ls -F --color=auto" -t A,B`
    Then the exit status should be 0
    And the output should contain:
    """
    Created shortcut.
    """
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    #A
    ==
    ls                            ls -F --color=auto

    #B
    ==
    ls                            ls -F --color=auto
    """

  Scenario: Create new shortcut with new tag
    Given I run `aka add ls "ls -FG" -t A,B`
    When I run `aka add ls "ls -FG" -t C`
    Then the exit status should be 0
    And the output should contain:
    """
    Created shortcut.
    """
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    #A
    ==
    ls                            ls -FG

    #B
    ==
    ls                            ls -FG

    #C
    ==
    ls                            ls -FG
    """

  Scenario: Don't overwrite existing shortcut
    Given I run `aka add ls "ls -F --color=auto"`
    When I run `aka add ls "ls -FG"`
    Then the exit status should not be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Shortcut "ls" exists. Pass --force to overwrite. Or provide a new --tag.

    """
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    Shortcut "ls" exists. Pass --force to overwrite. Or provide a new --tag.
    #default
    ========
    ls                            ls -F --color=auto
    """

  Scenario: Overwrite existing shortcut with force
    Given I run `aka add ls "ls -F --color=auto"`
    When I run `aka add ls "ls -FG" -f`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Overwrote shortcut.

    """
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    Overwrote shortcut.
    #default
    ========
    ls                            ls -FG
    """

  Scenario: Create new shortcut as function
    When I run `aka add ls "ls -F --color=auto" --function`
    Then the exit status should be 0
    And the output should contain:
    """
    Created shortcut.
    """
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    #default
    ========
    ls                            ls -F --color=auto
    """

  Scenario: Create new shortcut with description
    When I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls"`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    """
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    #default
    ========
    ls                            ls; ls; ls
    """
