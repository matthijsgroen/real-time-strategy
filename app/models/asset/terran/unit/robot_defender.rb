class Asset::Terran::Unit::RobotDefender < Asset::Base
  internal_name :robot_defender
  classifications :ground, :artillery
  hitpoints 400
  operating_costs 2.supply
  movement_speed 50.kmph
  sight 90.meters

  build_time 50.seconds
  build_costs 250.metal + 50.oil
  build_requires_presence_of :infantry_barracks # some heavy factory

  weapon :machine_gun, :targets => :ground, :range => 50.meters, :damage => 300.0 / 1.minute
  weapon :anti_air_missiles, :targets => :air, :range => 90.meters, :damage => 400.0 / 1.minute, :burst => 4.seconds

  has_ability :move, :attack #, :patrol, :stop
  after_ability :engage_near_hostiles, :except => :stop

end