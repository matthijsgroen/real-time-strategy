module Script::Parameter::Point

	def unserialize_point(parameter, parameters)
		options = self.class.parameter_options_for parameter
		assigned = nil
		found = nil
		[parameter, options[:alias]].compact.each do |param|
			if parameters[param].kind_of? Hash and
				parameters[param][:x].kind_of? Numeric and
				parameters[param][:y].kind_of? Numeric then
				assigned = Point.from_x_y(parameters[param][:x], parameters[param][:y])
			end
			if parameters[param].kind_of? Array and
				parameters[param].length == 2 and
				parameters[param][0].kind_of? Numeric and
				parameters[param][1].kind_of? Numeric then
				assigned = Point.from_x_y(parameters[param][0], parameters[param][1])
			end
			if parameters[param].kind_of? Asset::Base then
				assigned = parameters[param].location
			end

			assigned = parameters[param] if parameters[param].is_a? Point
			found = parameters[param]
		end
		raise "No Point found for required parameter :#{parameter}. #{found.class.name} found" if not assigned and options[:required]
		assigned
	end

	def serialize_point(parameter, value, parameters)
		options = self.class.parameter_options_for parameter
		case value
			when NilClass then parameters[parameter] = nil
			when Point then parameters[parameter] = { :x => value.x, :y => value.y }
			else raise "#{value.class.name} is not a valid Point"
		end
		value
	end

end