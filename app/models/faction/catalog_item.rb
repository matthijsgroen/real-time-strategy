class Faction::CatalogItem < ActiveRecord::Base
  set_table_name "faction_catalog_items"	
	belongs_to :catalog, :class_name => "Faction::Catalog"
end
