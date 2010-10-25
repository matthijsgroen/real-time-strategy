class Script::Terran::ReturnCargo < Script::Base
  internal_name :return_cargo

  include GameInstance::Positioning # for measuring and route calculation

  parameter :harvester, :type => :asset, :required => true, :alias => :asset
  parameter :refinery, :type => :asset

  SEARCH_LIMIT = 20.kilo.meters

  def roll
    scenario do |step|
      step.return_to_deliver_point
      step.deliver_cargo
    end
  end

  def metal_depleted_for_harvester
    done_delivering
  end

  private

  def return_to_deliver_point
    faction    = harvester.faction
    refineries = faction.assets.of_type(:ore_refinery).closest_at(self.harvester, SEARCH_LIMIT.to_distance)
    route, self.refinery = select_most_reachable_route_for harvester, refineries
    raise "no route or refinery found" unless route and self.refinery
    execute_subscript :move, :asset => harvester, :to => self.refinery, :target => self.refinery, :route => route
  end

  def deliver_cargo
    refinery.place_in self.harvester
    faction       = self.harvester.faction
    deliver_speed = 100.0 / 1.second
    #raise "delivering #{self.harvester.metal.inspect} #{(Time.now.utc - execution_time) / 60.0} minutes ago"
    faction.metal.increase :production, deliver_speed, execution_time
    harvester.metal.change :production, -deliver_speed, execution_time
  end

  def done_delivering
    faction       = self.harvester.faction
    deliver_speed = 100.0 / 1.second
    faction.metal.decrease :production, deliver_speed, execution_time
    harvester.metal.change :production, 0, execution_time
    refinery.release harvester
    finish!
    self.harvester.harvest :start_time => execution_time
  end

end