class Script::Generic::Move < Script::Base
	internal_name :move

	include GameInstance::Positioning # for measuring and route calculation

	parameter :asset, :type => :asset, :required => true
	parameter :destination, :type => :point, :required => true, :alias => :to 

	def asset_destroyed(time)
		puts "#{I18n.l execution_time, :format => "%H:%M:%S"} - #{self.asset.inspect} was killed"
		self.asset = nil
		finish!
	end

	def roll
		scenario do |step|
			step.move do
				current_position = asset.location
				length = distance current_position, destination
				duration = length / (asset.movement_speed.to_speed)

				# todo: calulating routes
				self.end_time = execution_time + duration
				Asset::Movement.create(:path => LineString.from_points([current_position, destination]),
															 :departure_at => execution_time, :arrival_at => self.end_time,
															 :asset_id => asset.id, :game_instance_id => game_instance.id)
			end
			step.arrive do
				asset.location = destination
				asset.movement.destroy if asset.movement
				asset.save
				finish!
			end
		end
	end

end