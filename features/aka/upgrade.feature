Feature: Upgrade aka
  In order to keep the aka configuration up to date
  I want to upgrade the configuration from the command-line
  So I don't have to do it manually

  Background:
    Given I set the AKA environment variable to the ".aka.db" file in the working directory
    And I set the environment variables to:
    | variable | value |
    | NO_MAN   | 1     |


  @ruby2.1.9_or_greater
  Scenario: Upgrade from v0 to v1
    Given a file named ".aka.db" with:
    """
    ---
    1: !ruby/object:OpenStruct
      table:
        :shortcut: ls
        :command: ls -F --color=auto
      modifiable: true

    """
    When I run `aka upgrade`
    # Then the exit status should be 0
    # Then the file ".aka.db" should contain exactly:
    # """
    # ---
    # :version: '1'
    # :shortcuts:
    #   1: !ruby/object:OpenStruct
    #     table:
    #       :shortcut: ls
    #       :command: ls -F --color=auto
    #     modifiable: true

    # """
    And the stdout should contain "Upgraded"
    And the stdout should contain ".aka.db"
    And the stdout should contain "Backed up to"
    And the stdout should contain ".aka.db.backup"
    And the file ".aka.db.backup" should contain exactly:
    """
    ---
    1: !ruby/object:OpenStruct
      table:
        :shortcut: ls
        :command: ls -F --color=auto
      modifiable: true

    """

  @ruby2.1.9_or_greater
  Scenario: Upgrade from v1 to v2
    Given a file named ".aka.db" with:
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
    :links:
    - !ruby/object:OpenStruct
      table:
        :tag:
        - os:darwin
        :output: ".aka.zsh"
      modifiable: true

    """
    When I run `aka upgrade`
    Then the exit status should be 0
    And the file ".aka.db" should contain exactly:
    """
    ---
    :version: '2'
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
    :links:
      1: !ruby/object:OpenStruct
        table:
          :tag:
          - os:darwin
          :output: ".aka.zsh"
        modifiable: true

    """
    And the stdout should contain "Upgraded"
    And the stdout should contain ".aka.db"
    And the stdout should contain "Backed up to"
    And the stdout should contain ".aka.db.backup"
    And the file ".aka.db.backup" should contain exactly:
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
    :links:
    - !ruby/object:OpenStruct
      table:
        :tag:
        - os:darwin
        :output: ".aka.zsh"
      modifiable: true

    """

  @ruby2.1.9_or_greater
  Scenario: Upgrade from v2 to v3
    Given a file named ".aka.db" with:
    """
    ---
    :version: '2'
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
    :links:
      1: !ruby/object:OpenStruct
        table:
          :tag:
          - os:darwin
          :output: ".aka.zsh"
        modifiable: true

    """
    When I run `aka upgrade`
    Then the exit status should be 0
    And the file ".aka.db" should exist
    When I run `aka list`
    Then the output should contain:
    """
    #os:linux
    =========
    ls                            ls; ls; ls

    =====
    Links
    =====

    [1] .aka.zsh: #os:darwin
    """
    And the stdout should contain "Upgraded"
    And the stdout should contain ".aka.db"
    And the stdout should contain "Backed up to"
    And the stdout should contain ".aka.db.backup"
    And the file ".aka.db.backup" should contain exactly:
    """
    ---
    :version: '2'
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
    :links:
      1: !ruby/object:OpenStruct
        table:
          :tag:
          - os:darwin
          :output: ".aka.zsh"
        modifiable: true

    """
