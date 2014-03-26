Feature: Remove keyboard shortcuts
  In order to improve productivity
  I want to have a tool for managing shell keyboard shortcuts
  So I don't have to do it myself

  Background:
    Given a file named ".aka.yml" should not exist
    And I set the AKA environment variable to the ".aka.yml" file in the working directory
    And I set the environment variables to:
    | variable | value |
    | NO_MAN   | 1     |

  Scenario: Remove shortcut
    Given I run `aka add ls "ls -F --color=auto"`
    When I run `aka remove ls`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Removed shortcut.

    """
    And the file ".aka.yml" should contain exactly:
    """
    ---
    :version: '1'
    :shortcuts: {}

    """

  Scenario: Remove missing shortcut
    Given I run `aka add ls "ls -F --color=auto"`
    When I run `aka remove ..`
    Then the exit status should not be 0
    And the output should contain exactly:
    """
    Created shortcut.
    No shortcut "..". Aborting.

    """
    And the file ".aka.yml" should contain exactly:
    """
    ---
    :version: '1'
    :shortcuts:
      1: !ruby/object:OpenStruct
        table:
          :shortcut: ls
          :command: ls -F --color=auto
        modifiable: true

    """
