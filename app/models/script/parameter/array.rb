module Script::Parameter::Array

	def unserialize_array(parameter, parameters)
		options = self.class.parameter_options_for parameter
		assigned = nil
		[parameter, options[:alias]].compact.each do |param|
			assigned = parameters[param] if parameters[param].kind_of? Array
		end
		raise "No Array found for required parameter :#{parameter}" if not assigned and options[:required]

		#puts "deserialize array: #{assigned.inspect}"
		typecast_method = "unserialize_#{options[:element_type]}"
		assigned ||= []
		assigned.collect { |item| send typecast_method, :item, { :item => item } }
	end

	def serialize_array(parameter, value, parameters)
		options = self.class.parameter_options_for parameter
		value ||= []
		raise "No valid Array: found #{value.class.name}" unless value.kind_of? Array
		typecast_method = "serialize_#{options[:element_type]}"

		array_values = value.collect do |item|
			item_catch = {}
			send typecast_method, :item, item, item_catch
			item_catch[:item]
		end

		parameters[parameter] = array_values
		value
	end

end