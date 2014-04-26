Feature: List keyboard shortcuts
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

  Scenario: List shortcuts
    Given I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    When I run `aka list`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    #default
    ========
    ..                            cd ..

    #os:linux
    =========
    ls                            ls; ls; ls

    #os:darwin
    ==========
    ls                            ls -FG


    """

  Scenario: List shortcuts matching tag
    Given I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add ... "cd ..." --tag os:windows`
    And I run `aka add .. "cd .."`
    When I run `aka list --tag os:darwin`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Created shortcut.
    #default
    ========
    ..                            cd ..

    #os:darwin
    ==========
    ls                            ls -FG

    2 shortcut(s) excluded (#os:linux, #os:windows).

    """
