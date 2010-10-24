
Given /^([^\s]+) has (\d+) ([^\s]*) at (\d+), (\d+)$/ do |faction_name, amount, unit_name, xpos, ypos|
	faction = get_faction(faction_name)
	unit_sym = unit_name.underscore.to_sym
  unit_type = Asset::Manager[unit_sym]
	x = (xpos.to_f / 1.grid).round.grid
	y = (ypos.to_f / 1.grid).round.grid
	
	amount.to_i.times do
		unit = unit_type.new(:location => Point.from_x_y(x, y))
		faction.assets << unit
		raise "Spawn failed: #{unit.errors.full_messages.to_sentence}" unless unit.save_without_build_requirements
	end
end

Given /^([^\s]+) has a ([^\s]*) at (\d+), (\d+) as ([^\s]*)$/ do |faction_name, unit_name, xpos, ypos, variable_name|
	@unit_listing ||= {}

	raise "Item name already in use: #{variable_name}" if @unit_listing.has_key? variable_name	

	faction = get_faction(faction_name)
	unit_sym = unit_name.underscore.to_sym
  unit_type = Asset::Manager[unit_sym]
	x = (xpos.to_f / 1.grid).round.grid
	y = (ypos.to_f / 1.grid).round.grid

	unit = unit_type.new(:location => Point.from_x_y(x, y))
	faction.assets << unit
	raise "Spawn failed: #{unit.errors.full_messages.to_sentence}" unless unit.save_without_build_requirements
	@unit_listing[variable_name] = unit
end

Given /^([^\s]+) has the following (units|buildings|assets):/ do |faction_name, naming, asset_table|
	faction = get_faction(faction_name)
	asset_table.hashes.each do |hash|
		unit_sym = hash['unit_type'].underscore.to_sym
		unit_type = Asset::Manager[unit_sym]
		unit = unit_type.new(:location => Point.from_x_y(hash['x'].to_i, hash['y'].to_i))
		faction.assets << unit
		raise "Spawn failed: #{unit.errors.full_messages.to_sentence}" unless unit.save_without_build_requirements
	end
end

Then /^([^\s]+) should have (\d+) ([^\s]*)$/ do |faction_name, amount, unit_name|
	faction = get_faction(faction_name)
	unit_sym = unit_name.underscore.to_sym
	found = faction.assets.of_type(unit_sym).count

	raise "Amount mismatch: #{found} #{Asset::Manager[unit_sym].internal_name} found and #{amount} expected" if amount.to_i != found
end

When /^([^\s]+) builds ([^\s]+) at (\d+), (\d+)$/ do |faction_name, catalog_item, xpos, ypos|
	Given "#{faction_name} selects the first 1 ColonyOutpost"

	begin
		faction = get_faction(faction_name)
		faction.active_selection.build_structure catalog_item.underscore.to_sym, :location => Point.from_x_y(xpos.to_i, ypos.to_i)
	rescue GameInstance::GameplayError => e
		puts "player message: #{e.message}"
		faction.messages << Faction::Message.new(:message => e.message)
	end
end


When /^([^\s]+) issues (train|upgrade|produce) ([^\s]+)$/ do |faction_name, action_type, catalog_item|
	faction = get_faction(faction_name)
	catalog_item_sym = catalog_item.underscore.to_sym

	faction.active_selection.send action_type, catalog_item_sym
end

When /^([^\s]+) issues "([^"]+)"$/ do |faction_name, direct_action|
	faction = get_faction(faction_name)
  faction.active_selection.send direct_action	
end

When /^([^\s]+) issues "([^"]+)" with location (\d+), (\d+)$/ do |faction_name, action, xpos, ypos|
	faction = get_faction(faction_name)
  faction.active_selection.send action, :destination => [xpos.to_i, ypos.to_i]
end

When /^([^\s]+) issues ([^\s]+) to "([^"]+)"$/ do |faction_name, variable_name, direct_action|
	Given "#{faction_name} clears the selection"
	And "#{faction_name} adds #{variable_name} to the selection"
	When "#{faction_name} issues \"#{direct_action}\""
end

When /^([^\s]+) issues ([^\s]+) to "([^"]+)" with location (\d+), (\d+)$/ do |faction_name, variable_name, action, xpos, ypos|
	Given "#{faction_name} clears the selection"
	And "#{faction_name} adds #{variable_name} to the selection"
	When "#{faction_name} issues \"#{action}\" with location #{xpos}, #{ypos}"
end
