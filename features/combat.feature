Feature: Combatting opponents
  In order to win a map
  the player of the game
  needs to be able to eliminate opponents

  Background:
    Given a new instance
    And a new faction named Red
    And a new faction named Blue

  Scenario: Marine demolishing building
    Given Red has 1 Marine at 100, 100
    And Blue has 1 InfantryBarrack at 512, 512
    And Red selects all Marine
    When Red issues "move" with location 510, 533
    And wait 10 minutes
    Then Blue should have 0 InfantryBarrack

  Scenario: 3 vs 1 Marine
    Given Red has 1 Marine at 100, 100
    And Blue has 1 Marine at 512, 512
    And Blue has 1 Marine at 512, 544
    And Blue has 1 Marine at 480, 512
    And Red selects all Marine
    When Red issues "move" with location 510, 533
    And wait 20 minutes
    Then Blue should have 3 Marine
    And Red should have 0 Marine

  Scenario: Aerial combat
    Given Red has 1 Interceptor at 100, 100
    And Blue has 1 Marine at 512, 512
    And Blue has 1 Marine at 512, 544
    And Blue has 1 Marine at 480, 512
    And Red selects all Interceptor
    When Red issues "move" with location 510, 533
    And wait 20 minutes
    Then Blue should have 0 Marine
    And Red should have 1 Interceptor

  Scenario: Ground to Air combat
    Given Red has 1 Interceptor at 100, 100
    And Blue has 1 RobotDefender at 300, 300
    And Red selects all Interceptor
    When Red issues "move" with location 300, 300
    And wait 20 minutes
    Then Blue should have 1 RobotDefender
    And Red should have 0 Interceptor

  Scenario: Ground to Air combat 2
    Given Red has 1 Interceptor at 100, 100
    And Blue has 1 RobotDefender at 300, 300
    And Blue selects all RobotDefender
    When Blue issues "move" with location 100, 100
    And wait 20 minutes
    Then Blue should have 1 RobotDefender
    And Red should have 0 Interceptor

  Scenario: Utilizing multiple weapons
    Given Red has 1 Marine at 200, 200
    And Red has 1 Interceptor at 40, 40
    And Blue has 1 RobotDefender at 300, 300
    And Blue has 1 RobotDefender at 303, 303
    And Blue selects all RobotDefender
    When Blue issues "move" with location 205, 205
    And wait 20 minutes
    And Blue issues "move" with location 40, 40
    And wait 20 minutes
    Then Blue should have 2 RobotDefender
    And Red should have 0 Marine
    And Red should have 0 Interceptor

  Scenario: Proximity fighting by passing a guntower
    Given Red has a Marine at 300, 200 as m1
    And Red has a Marine at 150, 150 as m2
    And Blue has 1 GunTower at 160, 500
    When Red issues m1 to "move" with location 300, 700
    And wait 20 minutes
    And Red issues m2 to "move" with location 150, 700
    And wait 20 minutes
    Then Red should have 1 Marine
    And Blue should have 1 GunTower
