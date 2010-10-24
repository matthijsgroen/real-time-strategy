class Asset::Terran::Unit::ConstructionRobot < Asset::Base
  internal_name :construction_robot
	classifications :workers, :ground
	hitpoints 500
	movement_speed 30.kmph

  build_time 1.minute + 30.seconds
  build_costs 300.oil + 450.metal

	has_ability :construct

end