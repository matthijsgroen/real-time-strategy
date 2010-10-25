class Asset::Terran::Building::OreRefinery < Asset::Base
  internal_name :ore_refinery
  classifications :ground, :resource, :building
  hitpoints 500

  build_time 2.minutes
  build_costs 25.oil + 175.metal
  build_requires_presence_of :colony_outpost
  building_size :width => 3, :height => 2
  exit_point [45, 20]

  operating_requires 0.energy

end