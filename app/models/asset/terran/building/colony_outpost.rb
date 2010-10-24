class Asset::Terran::Building::ColonyOutpost < Asset::Base
  internal_name :colony_outpost
	classifications :ground, :building
	hitpoints 500

  build_time 10.seconds
  build_costs 20.oil + 20.metal
	exit_point [45, 20]
	building_size :width => 3, :height => 2

	has_catalog_ability :build_terran_structure, [:infantry_barrack, :ore_refinery], :as => :build_structure

	after_create :add_construction_robot

	def add_construction_robot
		Asset::Terran::Unit::ConstructionRobot.create! :part_of => self, :bound_to => self
	end

end