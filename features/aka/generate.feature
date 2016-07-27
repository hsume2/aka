Feature: Generate commands for loading keyboard shortcuts into your shell
  In order to improve productivity
  I want to have a tool for managing shell keyboard shortcuts
  So I don't have to do it myself

  Background:
    Given a file named ".aka.yml" should not exist
    And I set the AKA environment variable to the ".aka.yml" file in the working directory
    And I set the environment variables to:
    | variable | value |
    | NO_MAN   | 1     |

  Scenario: Generate script to file
    Given I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    When I run `aka generate --output .aka.zsh`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Generated .aka.zsh.

    """
    And the file ".aka.zsh" should contain exactly:
    """
    alias ..="cd .."
    alias ls="ls -FG"
    function ls {
      ls -F --color=auto
    }

    """

  Scenario: Generate script to stdout
    Given I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    When I run `aka generate`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    alias ..="cd .."
    alias ls="ls -FG"
    function ls {
      ls -F --color=auto
    }

    """

  Scenario: Generate script matching tag
    Given I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    When I run `aka generate --tag os:darwin`
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    alias ..="cd .."
    alias ls="ls -FG"

    """
    And the stderr should contain exactly:
    """



    1 shortcut(s) excluded (#os:linux).
    """

  Scenario: Generate script with function
    Given I run `aka add ls "ls -F --color=auto" --function`
    When I run `aka generate --output .aka2.zsh`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Generated .aka2.zsh.

    """
    And the file ".aka2.zsh" should contain exactly:
    """
    function ls {
      ls -F --color=auto
    }

    """

  Scenario: Generate script shortcuts before functions
    Given I run `aka add ls "ls -F --color=auto" --function`
    And I run `aka add sc "script/console"`
    And I run `aka add sg "script/generate"`
    When I run `aka generate --output .aka.zsh`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Generated .aka.zsh.

    """
    And the file ".aka.zsh" should contain exactly:
    """
    alias sc="script/console"
    alias sg="script/generate"
    function ls {
      ls -F --color=auto
    }

    """
