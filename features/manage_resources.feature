Feature: Manage Resources
  In order to create an army and base
  the player of the game
  needs to delve for resources and be able to spend them

  Background:
    Given a new instance
    And a new faction named Red
    And Red has a primitive base at 100, 100

  Scenario: Delving Resources
    Given Red selects all OreHarvester
    And Red has the following resources:
      | amount | type  |
      | 0      | metal |
    When Red issues "harvest"
    And wait 30 minutes
    Then Red should have the following resources:
      | amount | type  |
      | 5000   | metal |

  Scenario: Spending Resources
    Given Red selects the first 1 InfantryBarrack
    And Red has the following resources:
      | amount | type  |
      | 100    | metal |
      | 50     | oil   |
    When Red issues train Marine
    Then Red should have the following resources:
      | amount | type  |
      | 25     | metal |
      | 50     | oil   |
