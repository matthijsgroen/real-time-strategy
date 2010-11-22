Feature: Manage Assets
  In order to create an army and base
  the player of the game
  wants to create and manage units 

  Background:
    Given a new instance
    And a new faction named Red

  Scenario: Creating a unit with a building queue
    Given Red has 1 ColonyOutpost at 100, 100
    And Red has 1 InfantryBarrack at 500, 500
    And Red has the following resources:
      | amount  | type  |
      | 500     | oil   |
      | 500     | metal |
    And Red selects the first 1 InfantryBarrack
    When Red issues train Marine
    And Red issues train Marine
    And wait 2 minutes
    Then Red should have 2 Marine

  Scenario: Moving a fast unit
    Given Red has 1 Marine at 10, 10
    And Red selects all Marine
    When Red issues "move" with location 30, 30
    And wait 2 minutes
    Then Red selected units should be at 30, 30

  Scenario: Moving a slow unit
    Given Red has 1 Marine at 10, 10
    And Red selects all Marine
    When Red issues "move" with location 3000, 3000
    And wait 1 second
    Then Red selected units should not be at 3000, 3000
    And Red selected units should not be at 10, 10

  Scenario: Constructing a building
    Given Red has 1 ColonyOutpost at 100, 100
    And Red has the following resources:
      | amount  | type  |
      | 5000    | oil   |
      | 5000    | metal |
    And Red selects the first 1 ColonyOutpost
    When Red builds InfantryBarrack at 500, 500
    And wait 12 minutes
    Then Red should have 1 InfantryBarrack

  Scenario: Mutating assets
    Given Red has 1 MobileConstructionVehicle at 100, 100
    And Red selects the first 1 MobileConstructionVehicle
    When Red issues "deploy"
    And wait 5 minutes
    Then Red should have 0 MobileConstructionVehicle
    And Red should have 1 ColonyOutpost 

  Scenario: Taking up space
    Given Red has 1 ColonyOutpost at 94, 94
    And Red has the following resources:
      | amount  | type  |
      | 5000    | oil   |
      | 5000    | metal |
    And Red selects the first 1 ColonyOutpost
    When Red builds InfantryBarrack at 100, 100
    And wait 5 minutes
    Then Red should have 0 InfantryBarrack
    And Red should have a message "Can't build there"
