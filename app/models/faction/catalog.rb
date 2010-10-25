class Faction::Catalog < ActiveRecord::Base
  set_table_name "faction_catalogs"
  belongs_to :faction, :class_name => "Faction::Base"
  has_many :items, :class_name => "Faction::CatalogItem"
end
