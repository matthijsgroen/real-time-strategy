class Asset::Terran::Unit::MobileConstructionVehicle < Asset::Base
  internal_name :mobile_construction_vehicle
  classifications :workers, :ground
  hitpoints 500
  operating_costs 4.supply
  movement_speed 10.kmph

  build_time 30.seconds
  build_costs 100.oil + 100.metal

  has_ability :move, :deploy

end