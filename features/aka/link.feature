Feature: Link keyboard shortcuts
  In order to keep my shortcuts up to date
  I want to have a tool for configuring shell keyboard shortcuts
  So I don't have to do it myself

  Background:
    Given a file named ".aka.db" should not exist
    And I set the AKA environment variable to the ".aka.db" file in the working directory
    And I set the environment variables to:
    | variable | value |
    | NO_MAN   | 1     |


  Scenario: Add a link
    Given I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    When I run `aka link --tag os:darwin --output .aka.zsh`
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Saved link.

    """
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Saved link.
    #default
    ========
    ..                            cd ..

    #os:linux
    =========
    ls                            ls; ls; ls

    #os:darwin
    ==========
    ls                            ls -FG

    =====
    Links
    =====

    [1] .aka.zsh: #os:darwin
    """

  Scenario: Add the same link
    Given I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    When I run `aka link --tag os:darwin --output .aka.zsh`
    And I run `aka link --tag os:darwin --output .aka.zsh`
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Saved link.
    Saved link.

    """
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Saved link.
    Saved link.
    #default
    ========
    ..                            cd ..

    #os:linux
    =========
    ls                            ls; ls; ls

    #os:darwin
    ==========
    ls                            ls -FG

    =====
    Links
    =====

    [1] .aka.zsh: #os:darwin
    """

  Scenario: Add a link with invalid options
    Given I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    When I run `aka link`
    Then the exit status should not be 0
    And the stdout should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.

    """
    And the stderr should contain exactly:
    """



    Invalid link.

    """
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Invalid link.
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

  Scenario: Remove a link
    Given I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    And I run `aka link --tag os:darwin --output .aka.zsh`
    When I run `aka link delete 1`
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Saved link.
    Deleted link.

    """
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Saved link.
    Deleted link.
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

  Scenario: Sync link
    Given a file named ".aka.zsh" should not exist
    And I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    And I run `aka link --tag os:darwin --output .aka.zsh`
    When I run `aka sync`
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Saved link.
    Generated .aka.zsh.

    """
    And the file ".aka.zsh" should contain:
    """
    alias ..="cd .."
    alias ls="ls -FG"

    """

  Scenario: Sync links
    Given a file named ".aka.zsh" should not exist
    And I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    And I run `aka link --tag os:darwin --output .aka.zsh`
    And I run `aka link --tag os:linux --output .aka2.zsh`
    When I run `aka sync`
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Saved link.
    Saved link.
    Generated .aka.zsh.
    Generated .aka2.zsh.

    """
    And the file ".aka.zsh" should contain:
    """
    alias ..="cd .."
    alias ls="ls -FG"

    """
    And the file ".aka2.zsh" should contain:
    """
    alias ..="cd .."
    function ls {
      ls -F --color=auto
    }

    """

  Scenario: Sync specific link
    Given a file named ".aka.zsh" should not exist
    And I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    And I run `aka link --tag os:darwin --output .aka.zsh`
    And I run `aka link --tag os:linux --output .aka2.zsh`
    When I run `aka sync 2`
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Saved link.
    Saved link.
    Generated .aka2.zsh.

    """
    And the file ".aka.zsh" should not exist
    And the file ".aka2.zsh" should contain:
    """
    alias ..="cd .."
    function ls {
      ls -F --color=auto
    }

    """

  Scenario: List links
    Given I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    And I run `aka link --tag os:darwin --output .aka.zsh`
    When I run `aka list`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Saved link.
    #default
    ========
    ..                            cd ..

    #os:linux
    =========
    ls                            ls; ls; ls

    #os:darwin
    ==========
    ls                            ls -FG

    =====
    Links
    =====

    [1] .aka.zsh: #os:darwin

    """
