module Asset::Support::Movement

	def self.included(base)
		base.extend(ClassMethods)
		base.class_eval do
			include Asset::Support::Movement::InstanceMethods

			has_one :movement, :class_name => "Asset::Movement", :dependent => :destroy, :foreign_key => "asset_id"
			has_many :approaching_assets, :class_name => "Asset::ProximityTrigger", :dependent => :destroy,
							 :foreign_key => "alerted_asset_id"
			has_many :assets_coming_in_proximity, :class_name => "Asset::ProximityTrigger", :dependent => :destroy,
							 :foreign_key => "asset_in_proximity_id"

			alias_method_chain :location, :movement
		end
	end

	module ClassMethods

		def exit_point value = nil
			@exit_point = value if value
			@exit_point
		end

	end

	module InstanceMethods

		# this should give the current location: e.g. the actual location in an movement action
		def location_with_movement
			return nil unless l = location_without_movement
			return l unless movement
			movement.location execution_time
		end

		def exit_point
			Point.from_x_y(location.x + self.class.exit_point[0], location.y + self.class.exit_point[1])
		end

	end

end