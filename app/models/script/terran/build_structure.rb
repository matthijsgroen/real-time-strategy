class Script::Terran::BuildStructure < Script::Base
	internal_name :build_terran_structure

	include GameInstance::Positioning # for measuring and route calculation

	parameter :yard, :type => :asset, :required => true, :alias => :asset
	parameter :location, :type => :point, :required => true, :alias => :at
	parameter :building_type, :type => :asset_type, :required => true, :alias => :item
	parameter :robot, :type => :asset
	parameter :constructed_asset, :type => :asset

	def roll
		scenario do |step|
			step.move_to_building_site
			step.start_building_construction
			step.return_after_construction
			step.move_robots_back_in_yard
		end
	end

	private

	def move_to_building_site
		# 0. use an instance of the product with the faction for determining the prices
		# this way faction's upgrades will be taken into account.
		product_instance = building_type.new :faction => yard.faction

		unless building_space_available?(location, product_instance.building_size)
			raise GameInstance::GameplayError.new(yard, "Can't build there", :no_build_space)
		end

		# 1. Pay for the product
		# 1a. check for enough resources
		product_instance.build_costs.each do |resource_type, amount|
			 raise GameInstance::GameplayError.new(yard, "not enough #{resource_type}", :no_resource) if faction.send(resource_type).amount(execution_time) < amount
		end
		# 1b. payment
		product_instance.build_costs.each do |resource_type, amount|
			 faction.send(resource_type).decrease :amount, amount, execution_time
		end

		# get a building robot
		self.robot = yard.assets.of_type(:construction_robot).first
		raise GameInstance::GameplayError.new(yard, "No robot available", :no_robot) unless self.robot
		yard.release self.robot

		execute_subscript :move, :asset => self.robot, :to => location
	end

	def start_building_construction
		begin
			build_script = execute_subscript :construct_asset, :asset_type => building_type,
																			 :location => building_location_for(building_type, location)
			self.constructed_asset = build_script.constructed_asset
			constructed_asset.place_in self.robot
		rescue
			finish_step # driving back...
		end
	end

	def return_after_construction
		constructed_asset.release self.robot if self.constructed_asset
		execute_subscript :move, :asset => self.robot, :to => self.yard.exit_point
	end

	def move_robots_back_in_yard
		self.yard.place_in self.robot
	end

end