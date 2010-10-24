class Faction::Selection < ActiveRecord::Base
  set_table_name "faction_selections"
	belongs_to :faction
	has_and_belongs_to_many :assets,
													:join_table => "faction_selected_assets",
													:class_name => "Asset::Base",
													:foreign_key => "selection_id",
													:association_foreign_key => "asset_id",
													:before_add => :clear_available_abilities,
													:after_remove => :clear_available_abilities

	validates_uniqueness_of :hotkey, :scope => :faction_id
	validates_inclusion_of :hotkey, :in => [nil] + (0..9).to_a

	def available_abilities
		@available_abilities ||= assets.distinct_types.collect { |type| type.class.abilities }.flatten.uniq
	end

	def respond_to_with_abilities?(method_id)
		return true if available_abilities.include? method_id.to_sym
		respond_to_without_abilities?(method_id)		
	end
	alias_method_chain :respond_to?, :abilities

	def method_missing_with_abilities(method_id, *args)
		if available_abilities.include? method_id.to_sym
			assets.each do |asset|
				asset.send method_id, *args if asset.respond_to? method_id
			end
		else
			method_missing_without_abilities method_id, *args
		end
	end
	alias_method_chain :method_missing, :abilities

	private

	def clear_available_abilities(item)
		@available_abilities = nil
	end

end
