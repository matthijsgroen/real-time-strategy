class Faction::Message < ActiveRecord::Base
	set_table_name "faction_messages"
  belongs_to :faction, :class_name => "Faction:::Base"

	validates_presence_of :message, :faction_id
end
