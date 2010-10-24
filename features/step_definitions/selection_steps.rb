Given /^([^\s]+) selects the (first|last) (\d+) ([^\s]*)$/ do |faction_name, start_end, amount, unit_name|
	Given "#{faction_name} clears the selection"
	Given "#{faction_name} adds the #{start_end} #{amount} #{unit_name} to selection"
end

Given /^([^\s]+) selects all ([^\s]*)$/ do |faction_name, unit_name|
	Given "#{faction_name} clears the selection"
	Given "#{faction_name} adds all #{unit_name} to selection"
end

Given /^([^\s]+) adds the (first|last) (\d+) ([^\s]*) to selection$/ do |faction_name, start_end, amount, unit_name|
	faction = get_faction faction_name
	unit_sym = unit_name.underscore.to_sym
	ordering = "created_at ASC, id ASC"
	ordering = "created_at DESC, id DESC" if start_end == "last"
	faction.active_selection.assets << faction.assets.of_type(unit_sym).all( :limit => amount.to_i, :order => ordering )
end

Given /^([^\s]+) adds all ([^\s]*) to selection$/ do |faction_name, unit_name|
	faction = get_faction faction_name
	unit_sym = unit_name.underscore.to_sym
	faction.active_selection.assets << faction.assets.of_type(unit_sym)
end

Then /^the selection of ([^\s]*) should be empty/ do |faction_name|
	faction = get_faction faction_name
  raise "Selection is not empty" unless faction.active_selection.assets.count.zero?
end

Given /^([^\s]+) adds the (\d+)(st|rd|nd|th) ([^\s]*) to selection$/ do |faction_name, offset, counter, unit_name|
	faction = get_faction faction_name
	unit_sym = unit_name.underscore.to_sym
	faction.active_selection.assets << faction.assets.of_type(unit_sym).all( :limit => 1,
																																					 :offset => offset.to_i - 1,
																																					 :order => "created_at ASC, id ASC" )
end

Given /^([^\s]+) adds ([^\s]*) to the selection$/ do |faction_name, variable_name|
	@unit_listing ||= {}
	faction = get_faction faction_name
	unit = @unit_listing[variable_name]
	raise "Unit with name: #{variable_name} could not be found" unless unit
	faction.active_selection.assets << unit
end

Given /^([^\s]+) clears the selection$/ do |faction_name|
	faction = get_faction faction_name
	faction.active_selection.assets.clear
end

Then /^the selection of ([^\s]+) should contain (\d+) ([^\s]*)$/ do |faction_name, amount, unit_name|
	faction = get_faction faction_name
	unit_sym = unit_name.underscore.to_sym

	found = faction.active_selection.assets.of_type(unit_sym).count
	raise "Amount mismatch: #{found} #{Asset::Manager[unit_sym].name} found and #{amount} expected" if amount.to_i != found
end

Then /^the (\d+)(st|rd|nd|th) ([^\s]*) should (not |)be in the selection of ([^\s]*)$/ do |offset, counter, unit_name, invert, faction_name|
	faction = get_faction faction_name
	unit_sym = unit_name.underscore.to_sym

	asset = faction.assets.of_type(unit_sym).all( :limit => 1, :order => "created_at ASC, id ASC",
																								:offset => offset.to_i - 1 )
	found = faction.active_selection.assets.find :first, :conditions => { :id => asset.first.id }

	raise "#{unit_name} found in selection" if found and invert.strip == "not"
	raise "#{unit_name} not found in selection" if not found and invert.strip != "not"
end

Then /^the selection of ([^\s]+) should contain:/ do |faction_name, asset_table|
	faction = get_faction faction_name
	asset_table.hashes.each do |hash|
		unit_sym = hash['unit_type'].underscore.to_sym
		found = faction.assets.of_type(unit_sym).count( :conditions => { :location => Point.from_x_y(hash['x'].to_i, hash['y'].to_i) } )
		raise "Asset not found #{hash['unit_type']} at #{hash['x']}, #{hash['y']}" if found.zero?
	end
end

Given /^wait (\d+) (minute|second|hour)(s?)$/ do |amount, time_unit, plural|
  time = amount.to_i
	time = case time_unit.to_sym
		when :second then time.seconds
		when :minute then time.minutes
		when :hour then time.hours
	end
	@instance.skip_time_with time
	@instance.update_world
end

Then /^([^\s]+) selected units should (not|)(\s?)be at (\d+), (\d+)$/ do |faction_name, inversion, dummy, x_pos, y_pos|
	faction = get_faction faction_name
	inverted = inversion == "not"
	faction.active_selection.assets.each do |asset|
		if not inverted
			raise "Asset #{asset.inspect} is not at #{x_pos}, #{y_pos}" unless asset.location.x == x_pos.to_i and asset.location.y == y_pos.to_i
		else
			raise "Asset #{asset.inspect} is at #{x_pos}, #{y_pos}" if asset.location.x == x_pos.to_i and asset.location.y == y_pos.to_i
		end
	end
end

Given /^([^\s]+) assigns the hotkey (\d+) to the selection$/ do |faction_name, hotkey_str|
	faction = get_faction faction_name
	faction.assign_selection_to hotkey_str.to_i
end

Given /^([^\s]+) calls selection with hotkey (\d+)$/ do |faction_name, hotkey_str|
	faction = get_faction faction_name
	faction.load_selection hotkey_str.to_i
end
