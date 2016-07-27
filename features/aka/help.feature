Feature: Help with aka
  In order to learn how to use aka
  I want to view help info in the command-line
  So I don't have to scour the web for information

  Background:
    Given I set the environment variables to:
    | variable | value |
    | NO_MAN   | 1     |

  Scenario: Run aka
    When I run `aka`
    Then the exit status should be 0
    And the output should contain:
    """
    aka - Manage Shell Keyboard Shortcuts
    """

  Scenario: Get help
    When I run `aka --help`
    Then the exit status should be 0
    And the output should contain:
    """
    aka - Manage Shell Keyboard Shortcuts
    """

  Scenario: Get help with invalid arguments
    When I run `aka -z`
    Then the exit status should be 64
    And the output should contain:
    """
    aka - Manage Shell Keyboard Shortcuts
    """

  Scenario: Get version
    When I run `aka --version`
    Then the exit status should be 0
    And the output should contain exactly:
    """
    aka version 0.4.0

    """

  Scenario: Help creating new shortcut
    When I run `aka -h add`
    Then the exit status should be 0
    And the output should contain:
    """
    aka-add - Add keyboard shortcuts
    """

  Scenario: Help listing shortcuts
    When I run `aka -h list`
    Then the exit status should be 0
    And the output should contain:
    """
    aka-list - List keyboard shortcuts
    """

  Scenario: Help generating shortcuts
    When I run `aka -h generate`
    Then the exit status should be 0
    And the output should contain "aka-generate"
    And the output should contain "Generate  commands for loading keyboard shortcuts into"

  Scenario: Help removing shortcuts
    When I run `aka -h remove`
    Then the exit status should be 0
    And the output should contain:
    """
    aka-remove - Remove keyboard shortcuts
    """

  Scenario: Help showing shortcuts
    When I run `aka -h show`
    Then the exit status should be 0
    And the output should contain:
    """
    aka-show - Show keyboard shortcuts
    """

  Scenario: Help editing shortcuts
    When I run `aka -h edit`
    Then the exit status should be 0
    And the output should contain:
    """
    aka-edit - Edit keyboard shortcuts
    """

  Scenario: Help linking shortcuts
    When I run `aka -h link`
    Then the exit status should be 0
    And the output should contain:
    """
    aka-link - Link keyboard shortcuts
    """

  Scenario: Help syncing shortcuts
    When I run `aka -h sync`
    Then the exit status should be 0
    And the output should contain:
    """
    aka-sync - Synchronize keyboard shortcuts
    """

  Scenario: Help upgrading shortcuts
    When I run `aka -h upgrade`
    Then the exit status should be 0
    And the output should contain:
    """
    aka-upgrade - Upgrade keyboard shortcuts
    """
