class Script::Terran::BaseDeploy < Script::Base
	internal_name :deploy

	include GameInstance::Positioning # for measuring and route calculation

	parameter :mcv, :type => :asset, :required => true, :alias => :asset
	parameter :destination, :type => :point, :alias => :at

	def roll
		scenario do |step|
			step.move_to_building_site
			step.start_deployment
		end
	end

	private

	def move_to_building_site
		self.destination ||= mcv.location
		building = Asset::Manager[:colony_outpost].new :faction => mcv.faction, :game_instance => game_instance
		raise "Building space not available" unless building_location_free? destination, building
		self.destination = middle_of_asset_for_position(destination, building)

		unless self.destination == mcv.location
			execute_subscript :move, :asset => mcv, :to => destination
		else
			finish_step
		end
	end

	def start_deployment
		building_type = Asset::Manager[:colony_outpost]
		raise "building type not found" unless building_type
		#building = building_type.new :faction => mcv.faction, :game_instance => game_instance
		build_script = execute_subscript :construct_asset, :asset_type => building_type,
																		 :location => building_location_for(building_type, self.destination)
		constructed_asset = build_script.constructed_asset
		mcv.destroy
		#TODO: select the constructed asset if the mvc was selected.

	end

end