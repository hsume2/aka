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
    And the file ".aka.yml" should contain exactly:
    """
    ---
    :version: '1'
    :shortcuts:
      1: !ruby/object:OpenStruct
        table:
          :shortcut: lsf
          :command: ls -F
          :description: |-
            1
            2
            3
          :function: true
          :tag:
          - zsh
          - bash
        modifiable: true

    """

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
    And the file ".aka.yml" should contain exactly:
    """
    ---
    :version: '1'
    :shortcuts:
      1: !ruby/object:OpenStruct
        table:
          :shortcut: lsf
          :command: ls -F
          :description: |-
            1
            2
            3
          :function: true
          :tag:
          - zsh
          - bash
        modifiable: true

    """

  Scenario: Edit: Missing shortcut
    When I run `aka edit ls`
    Then the exit status should not be 0
    And the output should contain exactly:
    """
    Shortcut not found.

    """
