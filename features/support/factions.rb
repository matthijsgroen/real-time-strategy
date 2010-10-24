module FactionsHelpers

  def add_faction(name)
		new_faction = Faction::Base.create(:game_instance_id => @instance.id, :name => name, :description => "Test faction")
		raise "Faction creation failed: #{new_faction.errors.full_messages.to_sentence}" unless new_faction.errors.empty?
		new_faction
  end

	def get_faction(name)
		result = Faction::Base.find_by_name_and_game_instance_id(name, @instance.id)
		raise "Faction not found: #{name}" unless result
		result
	end

end

World(FactionsHelpers)
