module Script::Parameter::Asset

  def unserialize_asset(parameter, parameters)
    options     = self.class.parameter_options_for parameter
    assigned    = nil
    possible_id = nil
    [parameter, options[:alias]].compact.each do |param|
      assigned = parameters[param] if parameters[param].kind_of? Asset::Base
      if possible_id = parameters[param.to_id] and not assigned
        begin
          assigned = Asset::Base.find possible_id
        rescue
        end
      end
    end
    raise "#{self.inspect}: No Asset found for required parameter :#{parameter}. tried keys: #{[parameter, options[:alias]].compact.inspect} tried ID #{possible_id}" if not assigned and options[:required]
    
    assigned
  end

  def serialize_asset(parameter, value, parameters)
    options                     = self.class.parameter_options_for parameter
    raise "No valid Asset: found #{value.class.name}" unless value.kind_of? Asset::Base or value.nil?
    parameters[parameter.to_id] = value.nil? ? nil : value.id

    assets << value if value and not asset_ids.include? value.id
    if value.nil? and old_key = parameters[parameter.to_id]
      old_value = Asset::Base.find old_key
      assets.delete old_value if old_value
    end
    #puts "s- assets attached to #{self.inspect} script: #{assets.inspect}"

    #puts "set #{self.class.internal_name}.#{parameter} = #{value.inspect} (#{parameters.inspect})"
    #raise "assigning value '#{value.id}' failed" if value and !parameters[parameter.to_id]

    value
  end

  def resource_notification(asset, resource, full_or_depleted, time)
    self.class.script_parameters_of_type(:asset).each do |asset_name|
      if parameters[asset_name.to_id] == asset.id
        method_name         = "#{resource}_#{full_or_depleted}_for_#{asset_name}"
        self.execution_time = time
        send method_name if respond_to? method_name
        return
      end
    end
  end

  def resource_group_notification(asset, resource_group, full_or_depleted, time)
    self.class.script_parameters_of_type(:asset).each do |asset_name|
      if parameters[asset_name.to_id] == asset.id
        method_name         = "#{resource_group}_#{full_or_depleted}_for_#{asset_name}"
        self.execution_time = time
        send method_name if respond_to? method_name
        return
      end
    end
  end

  def asset_notification(asset, message, time)
    self.class.script_parameters_of_type(:asset).each do |asset_name|
      if parameters[asset_name.to_id] == asset.id
        method_name         = "#{asset_name}_#{message}"
        self.execution_time = time
        send method_name, time if respond_to? method_name
        return
      end
    end
  end

end