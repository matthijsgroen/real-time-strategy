Given /^([^\s]+) has the following resources:/ do |faction_name, resource_table|
  faction = get_faction(faction_name)
  resource_table.hashes.each do |hash|
    resource = faction.resources.find_by_name hash['type']
    raise "Faction #{faction_name} does not have the resource #{hash['type']}" unless resource
    resource.change :amount, hash['amount'].to_i
  end
end

Then /^([^\s]+) should have the following resources:/ do |faction_name, resource_table|
  faction = get_faction(faction_name)
  resource_table.hashes.each do |hash|
    resource = faction.resources.find_by_name hash['type']
    raise "Difference in amount #{hash['type']}: #{hash['amount']} expected and #{resource.amount} found." if resource.amount != hash['amount'].to_i
  end
end