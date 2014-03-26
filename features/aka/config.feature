Feature: Configure keyboard shortcuts
  In order to keep my shortcuts up to date
  I want to have a tool for configuring shell keyboard shortcuts
  So I don't have to do it myself

  Background:
    Given a file named ".aka.yml" should not exist
    And I set the AKA environment variable to the ".aka.yml" file in the working directory
    And I set the environment variables to:
    | variable | value |
    | NO_MAN   | 1     |


  Scenario: Add a configuration
    Given I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    When I run `aka config --tag os:darwin --output .aka.zsh`
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Saved configuration.

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
          :tag:
          - os:linux
          :description: |-
            ls
            ls
            ls
          :function: true
        modifiable: true
      2: !ruby/object:OpenStruct
        table:
          :shortcut: ls
          :command: ls -FG
          :tag:
          - os:darwin
        modifiable: true
      3: !ruby/object:OpenStruct
        table:
          :shortcut: ..
          :command: cd ..
        modifiable: true
    :configs:
    - !ruby/object:OpenStruct
      table:
        :tag:
        - os:darwin
        :output: .aka.zsh
      modifiable: true

    """

  Scenario: Sync a configuration
    Given a file named ".aka.zsh" should not exist
    And I run `aka add ls "ls -F --color=auto" --description "ls\nls\nls" --function --tag os:linux`
    And I run `aka add ls "ls -FG" --tag os:darwin`
    And I run `aka add .. "cd .."`
    And I run `aka config --tag os:darwin --output .aka.zsh`
    When I run `aka sync`
    Then the exit status should be 0
    And the stdout should contain exactly:
    """
    Created shortcut.
    Created shortcut.
    Created shortcut.
    Saved configuration.

    """
    And the file ".aka.zsh" should contain exactly:
    """
    alias ..="cd .."
    alias ls="ls -FG"
    function ls {
      ls -F --color=auto
    }

    """
