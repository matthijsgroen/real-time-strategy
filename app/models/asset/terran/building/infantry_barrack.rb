class Asset::Terran::Building::InfantryBarrack < Asset::Base
  internal_name :infantry_barrack
	classifications :ground, :military, :building
	hitpoints 500

  build_time 10.seconds
  build_costs 75.oil + 175.metal
  build_requires_presence_of :colony_outpost

  operating_requires 30.energy
	queue_size 5
	exit_point [45, 20]
	building_size :width => 3, :height => 2

	has_catalog_ability :produce, [:marine], :as => :train

end