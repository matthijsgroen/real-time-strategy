class Asset::Terran::Unit::OreHarvester < Asset::Base
  internal_name :ore_harvester
	classifications :workers, :ground
	hitpoints 500
	operating_costs 2.supply
	movement_speed 8.kmph

  build_time 2.minutes + 30.seconds
  build_costs 400.oil + 1000.metal

	has_resource :metal, :limit => 600, :amount => 0

	has_ability :move, :harvest, :return_cargo

end