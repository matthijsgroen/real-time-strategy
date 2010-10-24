class Asset::Terran::Unit::Interceptor < Asset::Base
  internal_name :interceptor
  classifications :air
  hitpoints 600
  operating_costs 2.supply
  movement_speed 120.kmph
  sight 150.meters

  build_time 90.seconds
  build_costs 550.metal + 150.oil
  build_requires_presence_of :infantry_barracks # some flight producing building or command tower

  weapon :lasers, :targets => :ground, :range => 120.meters, :damage => 200.0 / 1.minute, :burst => 3.seconds

  has_ability :move, :attack #, :patrol, :stop
  after_ability :engage_near_hostiles, :except => :stop

end