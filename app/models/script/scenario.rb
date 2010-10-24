class Script::Scenario

	def initialize(script, position)
		@script = script
		@steps = []
		@executed = false
		@position = position
	end

	def respond_to? method_id, include_private_methods = false
		true
	end

	def method_missing(method_id, *args)
		@steps << method_id
		if @steps.length == @position + 1 and not @executed

#			indentation = ""
#			om = @script;	while om.parent; indentation += "  "; om = om.parent;	end
#			puts "#{indentation}- #{@script.class.internal_name} #{@script.position}. #{method_id} @ #{@script.execution_time}"

			@executed = true
			if block_given?
				yield
			else
				@script.send method_id, *args
			end
		end
	end

	def executed?
		@executed
	end

end