class Asset::Terran::Building::GunTower < Asset::Base
  internal_name :gun_tower
  classifications :ground, :building, :military
  hitpoints 400
  sight 150.meters

  build_time 80.seconds
  build_costs 150.metal

  weapon :machine_gun, :targets => :ground, :range => 150.meters, :damage => 800.0 / 1.minute

  has_ability :attack
  after_ability :engage_near_hostiles

end