class Script::Terran::HarvestOre < Script::Base
	internal_name :harvest

	include GameInstance::Positioning # for measuring and route calculation

	parameter :harvester, :type => :asset, :required => true, :alias => :asset
	parameter :ore_node, :type => :asset

	SEARCH_LIMIT = 20.kilo.meters

	def roll
		scenario do |step|
			step.search_ore_field
			step.start_harvesting
		end
	end

	def metal_depleted_for_ore_node
		#puts "stopped harvesting at #{execution_time}: ore node depleted"
		stop_harvesting
	end

	def metal_full_for_harvester
		#puts "stopped harvesting at #{execution_time}: harvester full #{self.harvester.metal.amount(execution_time)}, ore node has #{self.ore_node.metal.amount(execution_time)} metal left"
		stop_harvesting
	end

	private

	def search_ore_field
		nodes = game_instance.assets.of_type(:ore_field).closest_at(harvester, SEARCH_LIMIT.to_distance)
		
		route, self.ore_node = select_most_reachable_route_for harvester, nodes
		unless route and self.ore_node
			raise GameInstance::GameplayError.new(harvester, "no ore nodes nearby", :no_ore_nodes)	
		end
		execute_subscript :move, :asset => harvester, :to => self.ore_node, :target => self.ore_node, :route => route
	end

	def start_harvesting
		# TODO: Check if we arrived, else go to step 1.
		harvest_speed = 10.0 / 2.seconds
		self.ore_node.metal.decrease :production, harvest_speed, execution_time
		self.harvester.metal.increase :production, harvest_speed, execution_time
	end

	def stop_harvesting
		harvest_speed = 10.0 / 2.seconds
		self.ore_node.metal.increase :production, harvest_speed, execution_time
		self.harvester.metal.change :production, 0, execution_time
		finish!
		self.harvester.return_cargo :start_time => execution_time
	end

end