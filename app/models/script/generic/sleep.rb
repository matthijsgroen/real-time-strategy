class Script::Generic::Sleep < Script::Base
	internal_name :sleep

	# sleep script
	parameter :duration, :type => :integer, :required => true

	def roll
		scenario do |step|
			step.wait do
				self.end_time = execution_time + duration
			end
		end
	end

end