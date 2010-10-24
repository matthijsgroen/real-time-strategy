Feature: Manage unit selections
  In order to organize game units easier
  the player of the game
  wants to manage selections under hotkeys

  Background:
    Given a new instance
    And a new faction named Red

  Scenario: Selecting units
    Given Red has the following units:
      | unit_type | x  | y  |
      | Marine    | 10 | 10 |
      | Marine    | 20 | 20 |
      | Marine    | 20 | 10 |
      | Marine    | 10 | 20 |
    When Red selects the last 2 Marine
    And Red adds the 1st Marine to selection
    Then the selection of Red should contain:
      | unit_type | x  | y  |
      | Marine    | 10 | 10 |
      | Marine    | 20 | 10 |
      | Marine    | 10 | 20 |

  Scenario: Clearing the selection
    Given Red has 2 MobileConstructionVehicle at 10, 10
    And Red adds the first 2 MobileConstructionVehicle to selection
    When Red clears the selection
    Then the selection of Red should be empty

  Scenario: Assigning a hotkey to a selection
    Given Red has the following units:
      | unit_type | x  | y  |
      | Marine    | 10 | 10 |
      | Marine    | 20 | 20 |
      | Marine    | 20 | 10 |
      | Marine    | 10 | 20 |
    And Red selects the first 2 Marine
    When Red assigns the hotkey 1 to the selection
    And Red clears the selection
    Then the selection of Red should be empty
    When Red calls selection with hotkey 1
    Then the selection of Red should contain:
      | unit_type | x  | y  |
      | Marine    | 10 | 10 |
      | Marine    | 20 | 20 |
