module Script::Support::Parameter

	module ClassMethods

		def parameter(name, options = {})
			raise "Type missing" unless options[:type]
			@script_parameters ||= []
			raise "Parameter already defined" if @script_parameters.include? name
			@script_parameters << name
			@script_parameter_options ||= {}
			@script_parameter_options[name] = options
			@script_parameters_by_type ||= {}
			@script_parameters_by_type[options[:type]] ||= []
			@script_parameters_by_type[options[:type]] << name

			method_definition = <<-EOC
				def #{name}
					@param_values ||= {}
					@param_values[:#{name}] ||= unserialize_#{options[:type]}(:#{name}, self.parameters)
				end

				def #{name}=(value)
					@param_values ||= {}
					@param_values[:#{name}] = serialize_#{options[:type]}(:#{name}, value, self.parameters)
				end
			EOC
			class_eval(method_definition, __FILE__, __LINE__)			
		end

		def script_parameters
			@script_parameters
		end

		def script_parameters_of_type(type)
			@script_parameters_by_type[type]
		end

		def parameter_options_for(name)
			@script_parameter_options[name]
		end

	end

	module InstanceMethods

		def load_parameters_from(options)
			allowed_scopes = [nil, :public]
			self.class.script_parameters.each do |parameter|
				param_options = self.class.parameter_options_for parameter
				if allowed_scopes.include? param_options[:scope]
					value = self.send "unserialize_#{param_options[:type]}", parameter, options
					self.send "serialize_#{param_options[:type]}", parameter, value, self.parameters
				end
			end
		end

		private

		def serialize_parameters
			self.class.script_parameters.each do |parameter|
				param_options = self.class.parameter_options_for parameter
				#if [:array].include? param_options[:type]
				value = self.send parameter
				self.send "serialize_#{param_options[:type]}", parameter, value, self.parameters
				#end
			end
			#puts "serializing -- #{self.class.internal_name}: #{self.parameters.inspect}"
		end

	end

	def self.included(base)
		base.extend(ClassMethods)
		base.class_eval do
			include Script::Support::Parameter::InstanceMethods
			include Script::Parameter::Asset
			include Script::Parameter::AssetType
			include Script::Parameter::Point
			include Script::Parameter::Array

			before_save :serialize_parameters
		end
	end

end