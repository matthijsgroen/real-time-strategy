module GameInstance::Positioning

	GRID_SIZE = 32

	def distance(point_a, point_b)
		x = point_b.x - point_a.x
		y = point_b.y - point_a.y
		Math.sqrt((x * x) + (y * y)).to_f		
	end

	def select_most_reachable_route_for(asset, assets)
		#TODO: Implement this
		[{ :points => [] }, assets.first]
	end

	def middle_of_asset_for_position(point, asset)
		middle = { :width => ((asset.building_size[:width] * GRID_SIZE) / 2.0), :height => ((asset.building_size[:height] * GRID_SIZE) / 2.0) }
		point_x = (point.x - middle[:width])
		point_y = (point.y - middle[:height])
		Point.from_x_y point_x - (point_x % GRID_SIZE) + middle[:width], point_y - (point_y % GRID_SIZE) + middle[:height]
	end

	def building_location_free?(point, asset)
		middle = { :width => ((asset.building_size[:width] * GRID_SIZE) / 2.0), :height => ((asset.building_size[:height] * GRID_SIZE) / 2.0) }
		point_x = (point.x - middle[:width])
		point_y = (point.y - middle[:height])

		location = Point.from_x_y point_x - (point_x % GRID_SIZE), point_y - (point_y % GRID_SIZE)
		building_space_available?(location, asset.building_size)
	end

	def building_location_for(asset_type, point)
		s = asset_type.new.building_size
		middle = { :width => ((s[:width] * GRID_SIZE) / 2.0), :height => ((s[:height] * GRID_SIZE) / 2.0) }
		point_x = (point.x - middle[:width])
		point_y = (point.y - middle[:height])

		Point.from_x_y(point_x - (point_x % GRID_SIZE), point_y - (point_y % GRID_SIZE))
	end

	def grid_position?(point)
		((point.x % GRID_SIZE) + (point.y % GRID_SIZE)).zero? 
	end

	def building_space_available?(point, size)
		space_occupied = game_instance.assets.find_by_ground_space [
			[point.x, point.y],
			[point.x - 1 + size[:width].grid, point.y - 1 + size[:height].grid]
		]
		return false if space_occupied
		true
	end


end