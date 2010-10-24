Given /^a new instance$/ do
  @instance = GameInstance.create
  raise "Instance creation failed: #{@instance.errors.full_messages.to_sentence}" unless @instance.errors.empty?
end

Given /^a new faction named ([^\s]+)$/ do |name|
  f = add_faction name
  f.catalogs.add_full_catalogs_of :infantry_barrack
  f.catalogs.add_full_catalogs_of :colony_outpost
end

Given /^a new instance with faction ([^\s]+)$/ do |name|
  Given "a new instance"
  Given "a new faction named #{name}"
end

Given /^([^\s]+) has a (primitive|medium|advanced) base at (\d+), (\d+)$/ do |faction_name, base_type, xpos, ypos|
  x = xpos.to_i
  y = ypos.to_i

  Given "#{faction_name} has 1 ColonyOutpost at #{x}, #{y}"
  Given "#{faction_name} has 1 InfantryBarrack at #{x + 6.grid}, #{y}"
  Given "#{faction_name} has 1 OreRefinery at #{x}, #{y + 6.grid}"
  Given "#{faction_name} has 1 OreHarvester at #{x+5}, #{y + 12.grid}"
  Given "#{faction_name} has 1 OreField at #{x+10.grid}, #{y + 20.grid}"
end

Then /^([^\s]+) should have a message \"([^"]+)\"$/ do |faction_name, message|
  faction = get_faction(faction_name)
  found = faction.messages.find_by_message message
  raise "Message was not found" unless found
end