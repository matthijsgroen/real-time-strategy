class Asset::Terran::Unit::Marine < Asset::Base
  internal_name :marine
  classifications :infantry, :ground
  hitpoints 150
  operating_costs 1.supply
  movement_speed 5.kmph
  sight 60.meters

  build_time 10.seconds
  build_costs 75.metal
  build_requires_presence_of :infantry_barracks

  weapon :assault_rifle, :targets => :ground, :range => 50.meters, :damage => 100.0 / 1.minute

  has_ability :move, :attack #, :patrol, :attack, :stop
  after_ability :engage_near_hostiles, :except => :stop

end