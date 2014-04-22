Feature: Upgrade aka
  In order to keep the aka configuration up to date
  I want to upgrade the configuration from the command-line
  So I don't have to do it manually

  Background:
    Given I set the AKA environment variable to the ".aka.yml" file in the working directory
    And I set the AKA_LINK environment variable to the ".aka.link" file in the working directory
    And I set the environment variables to:
    | variable | value |
    | NO_MAN   | 1     |


  Scenario: Upgrade from v0 to v1
    Given a file named ".aka.yml" with:
    """
    ---
    1: !ruby/object:OpenStruct
      table:
        :shortcut: ls
        :command: ls -F --color=auto
      modifiable: true

    """
    When I run `aka upgrade`
    Then the exit status should be 0
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
    And the stdout should contain "Upgraded"
    And the stdout should contain ".aka.yml"
    And the stdout should contain "Backed up to"
    And the stdout should contain ".aka.yml.backup"
    And the file ".aka.yml.backup" should contain exactly:
    """
    ---
    1: !ruby/object:OpenStruct
      table:
        :shortcut: ls
        :command: ls -F --color=auto
      modifiable: true

    """

  Scenario: Upgrade from v1 to v2
    Given a file named ".aka.yml" with:
    """
    ---
    :version: '1'
    :shortcuts:
      1: !ruby/object:OpenStruct
        table:
          :shortcut: ls
          :command: ls -F --color=auto
        modifiable: true
    :links:
    - !ruby/object:OpenStruct
      table:
        :tag:
        - os:darwin
        :output: .aka.zsh
      modifiable: true

    """
    When I run `aka upgrade`
    Then the exit status should be 0
    And the file ".aka.yml" should contain exactly:
    """
    ---
    :version: '2'
    :shortcuts:
      1: !ruby/object:OpenStruct
        table:
          :shortcut: ls
          :command: ls -F --color=auto
        modifiable: true

    """
    And the file ".aka.link" should contain exactly:
    """
    ---
    - !ruby/object:OpenStruct
      table:
        :tag:
        - os:darwin
        :output: .aka.zsh
      modifiable: true

    """
    And the stdout should contain "Upgraded"
    And the stdout should contain ".aka.yml"
    And the stdout should contain "Backed up to"
    And the stdout should contain ".aka.yml.backup"
    And the file ".aka.yml.backup" should contain exactly:
    """
    ---
    :version: '1'
    :shortcuts:
      1: !ruby/object:OpenStruct
        table:
          :shortcut: ls
          :command: ls -F --color=auto
        modifiable: true
    :links:
    - !ruby/object:OpenStruct
      table:
        :tag:
        - os:darwin
        :output: .aka.zsh
      modifiable: true

    """
