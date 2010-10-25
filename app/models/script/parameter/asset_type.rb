module Script::Parameter::AssetType

  def unserialize_asset_type(parameter, parameters)
    options  = self.class.parameter_options_for(parameter) || {}
    assigned = nil
    [parameter, options[:alias]].compact.each do |param|
      if parameters[param].is_a? String and not assigned
        begin
          possible_class = parameters[param].constantize
          assigned = possible_class if possible_class.superclass == Asset::Base
        rescue
        end
      elsif parameters[param].is_a? Symbol and not assigned
        begin
          possible_class = Asset::Manager[parameters[param]]
          assigned = possible_class if possible_class.superclass == Asset::Base
        rescue
        end
      elsif !parameters[param].nil? and parameters[param].superclass == Asset::Base
        assigned = parameters[param]
      end
    end
    raise "No Asset found for required parameter :#{parameter}" if not assigned and options[:required]
    assigned
  end

  def serialize_asset_type(parameter, value, parameters)
    options               = self.class.parameter_options_for parameter
    raise "No valid AssetType: found #{value.name}" unless value.superclass == Asset::Base

    parameters[parameter] = value.internal_name
    value
  end

end