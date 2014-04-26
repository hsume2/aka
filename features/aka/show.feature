Feature: Show keyboard shortcuts
  In order to improve productivity
  I want to have a tool for managing shell keyboard shortcuts
  So I don't have to do it myself

  Background:
    Given a file named ".aka.yml" should not exist
    And I set the AKA environment variable to the ".aka.yml" file in the working directory
    And I set the AKA_LINK environment variable to the ".aka.link.yml" file in the working directory
    And I set the environment variables to:
    | variable | value |
    | NO_MAN   | 1     |

  Scenario: Show shortcut
    Given I run `aka add ls "ls -F --color=auto" --function --description "1\n2" --tag osx`
    When I run `aka show ls`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Shortcut: ls
    Description:
    1
    2
    Function: y
    Tags: #osx
    Command:
    ls -F --color=auto

    """

  Scenario: Show missing shortcut
    When I run `aka show ls`
    Then the exit status should not be 0
    And the output should contain exactly:
    """
    Shortcut not found.

    """
